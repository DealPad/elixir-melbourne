defmodule ElixirMelbourneWeb.Meetings.Questions do
  @moduledoc """
    Page for QA during meetup
  """
  use ElixirMelbourneWeb, :live_view
  alias ElixirMelbourne.Meetings.{Attendee, Question, QuestionVote}
  alias ElixirMelbourne.Meetings
  alias ElixirMelbourneWeb.Presence

  def mount(%{"room_id" => room_id}, params, socket) do
    topic = get_room_topic(room_id)
    maybe_attendee_id = Map.get(params, "attendee_id", nil)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(ElixirMelbourne.PubSub, topic)

      if maybe_attendee_id do
        attendee_id = maybe_attendee_id

        Presence.track(
          self(),
          topic,
          attendee_id,
          %{}
        )
      end
    end

    {:ok,
     socket
     |> assign(:active_link, "meetings")
     |> assign(:maybe_attendee_id, maybe_attendee_id)
     |> assign(:changeset, Question.changeset(%Question{}, %{}))
     |> assign(:questions, Meetings.list_questions_by_room_id(room_id))
     |> assign(:room_id, room_id)
     |> assign(:attendees, [])}
  end

  def handle_event("submit", %{"question" => question}, socket) do
    case question
         |> Map.put("attendee_id", socket.assigns.maybe_attendee_id)
         |> Map.put("room_id", socket.assigns.room_id)
         |> Meetings.create_question() do
      {:ok, %Question{room_id: room_id}} ->
        Phoenix.PubSub.broadcast(ElixirMelbourne.PubSub, "room: #{room_id}", :question_updated)
        {:noreply, socket |> assign(:changeset, Question.changeset(%Question{}, %{}))}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("resolve", %{"question-id" => question_id}, socket) do
    case Meetings.resolve_question(question_id) do
      {:ok, %Question{}} ->
        Phoenix.PubSub.broadcast(
          ElixirMelbourne.PubSub,
          "room: #{socket.assigns.room_id}",
          :question_updated
        )

        {:noreply, put_flash(socket, :info, "Question resolved")}

      _ ->
        {:noreply, put_flash(socket, :error, "Oops, something went wrong!")}
    end
  end

  def handle_event("unresolve", %{"question-id" => question_id}, socket) do
    case Meetings.unresolve_question(question_id) do
      {:ok, %Question{}} ->
        Phoenix.PubSub.broadcast(
          ElixirMelbourne.PubSub,
          "room: #{socket.assigns.room_id}",
          :question_updated
        )

        {:noreply, put_flash(socket, :info, "Question has been unresolved")}

      _ ->
        {:noreply, put_flash(socket, :error, "Oops, something went wrong!")}
    end
  end

  def handle_event("vote", %{"question-id" => question_id}, socket) do
    case Meetings.create_question_vote(%{
           question_id: question_id,
           attendee_id: socket.assigns.maybe_attendee_id
         }) do
      {:ok, %QuestionVote{}} ->
        Phoenix.PubSub.broadcast(
          ElixirMelbourne.PubSub,
          "room: #{socket.assigns.room_id}",
          :question_updated
        )

        {:noreply, socket}

      _ ->
        {:noreply, put_flash(socket, :error, "Oops, something went wrong!")}
    end
  end

  def handle_event("unvote", %{"question-id" => question_id}, socket) do
    with %QuestionVote{} = question_vote <-
           %{
             question_id: question_id,
             attendee_id: socket.assigns.maybe_attendee_id
           }
           |> Meetings.get_question_vote_by(),
         {:ok, %QuestionVote{}} <- Meetings.delete_question_vote(question_vote) do
      Phoenix.PubSub.broadcast(
        ElixirMelbourne.PubSub,
        "room: #{socket.assigns.room_id}",
        :question_updated
      )

      {:noreply, socket}
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Oops, something went wrong!")}
    end
  end

  def handle_info(
        %{event: "presence_diff"},
        %{assigns: %{room_id: room_id}} = socket
      ) do
    attendees =
      room_id
      |> get_room_topic()
      |> Presence.list()
      |> Map.keys()
      |> resolve_attendees_from_ids([])

    {:noreply, socket |> assign(:attendees, attendees)}
  end

  def handle_info(:question_updated, %{assigns: %{room_id: room_id}} = socket) do
    {:noreply,
     socket
     |> assign(%{
       questions: Meetings.list_questions_by_room_id(room_id)
     })}
  end

  defp get_room_topic(room_id), do: "room: #{room_id}"

  defp resolve_attendees_from_ids([attendee_id | attendee_ids], results) do
    case Meetings.maybe_get_attendee(attendee_id) do
      %Attendee{} = attendee ->
        resolve_attendees_from_ids(attendee_ids, [attendee] ++ results)

      _ ->
        resolve_attendees_from_ids(attendee_ids, results)
    end
  end

  defp resolve_attendees_from_ids(_, results), do: results

  defp already_vote?(
         [
           %QuestionVote{
             attendee_id: attendee_id
           }
           | _
         ],
         current_attendee_id
       )
       when current_attendee_id == attendee_id,
       do: true

  defp already_vote?([_ | votes], current_attendee_id),
    do: already_vote?(votes, current_attendee_id)

  defp already_vote?([], _), do: false

  def render(assigns) do
    ~H"""
      <div class="space-y-8">
        <div class="space-y-1">
          <p class="text-2xl font-semibold">
            Welcome to room code: <%= @room_id %>!
          </p>
          <p>
            You can share this code or this page link to invite others.
          </p>
        <.qrcode room_id={@room_id} socket={@socket}/>
        </div>
        <.username maybe_attendee_id={@maybe_attendee_id} socket={@socket} room_id={@room_id} />
        <.form let={f} for={@changeset} phx-submit="submit" class="border border-gray-200 dark:border-gray-600 rounded-lg p-4">
          <div class="space-y-6">
            <p class="text-xl font-medium">
              Enter your question
            </p>
            <div class="flex gap-4">
              <%= text_input f, :content, phx_debounce: "blur", class: "input" %>
              <button class="btn" type="submit">Submit</button>
            </div>
          </div>
        </.form>
        <div class="space-y-4">
          <%= for question <- @questions |> Enum.group_by(&{&1.resolved_at == nil}) |> Map.get({true}, []) do %>
            <%= render_question(assigns, question) %>
          <% end %>
        </div>
        <div class="h-px bg-gray-200 dark:bg-gray-600" />
        <div class="space-y-4">
          <%= for question <- @questions |> Enum.group_by(&{&1.resolved_at == nil}) |> Map.get({false}, []) do %>
            <%= render_question(assigns, question) %>
          <% end %>
        </div>
        <div class="h-px bg-gray-200 dark:bg-gray-600" />
        <%= if Enum.count(@attendees) > 0 do %>
          <div>
            <p class="text-lg font-medium">People who are in the room:</p>
            <ol class="list-decimal list-inside">
              <%= for attendee <- @attendees do %>
                <li><%= attendee.username %></li>
              <% end %>
            </ol>
          </div>
        <% end %>
      </div>
    """
  end

  defp username(assigns) do
    ~H"""
      <%= if !@maybe_attendee_id do %>
      <div class="fixed inset-0 z-40" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="fixed inset-0 backdrop-blur-md" />
        <div class="flex flex-col items-center p-6 h-full">
          <div class="flex-1" />
          <div class="overflow-y-auto relative w-full max-w-lg bg-white dark:bg-cod-gray rounded-lg shadow-lg p-6 space-y-8">
            <p class="text-xl font-medium">
              To join this meeting, please enter your username.
            </p>
            <form method="post" action={Routes.session_path(@socket, :set)}>
              <div class="flex items-end gap-4">
                <div class="flex-1 min-w-0">
                  <label for="username" class="block text-sm font-medium">Username</label>
                  <div class="mt-1">
                    <input type="text" name="username" id="username" class="input" />
                  </div>
                </div>
                <input hidden name="return_to" value={Routes.live_path(@socket, __MODULE__, @room_id)} />
                <button class="btn" type="submit">Save</button>
              </div>
            </form>
          </div>
          <div class="flex-1" />
        </div>
      </div>
    <% end %>
    """
  end

  defp qrcode(assigns) do
    ~H"""
      <div class="pt-1">
      <button phx-click={Phoenix.LiveView.JS.remove_class("hidden", to: "#qrcode-modal")}>
        <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v1m6 11h2m-6 0h-2v4m0-11v3m0 0h.01M12 12h4.01M16 20h4M4 12h4m12 0h.01M5 8h2a1 1 0 001-1V5a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1zm12 0h2a1 1 0 001-1V5a1 1 0 00-1-1h-2a1 1 0 00-1 1v2a1 1 0 001 1zM5 20h2a1 1 0 001-1v-2a1 1 0 00-1-1H5a1 1 0 00-1 1v2a1 1 0 001 1z" />
        </svg>
      </button>
      <div class="fixed inset-0 z-40 hidden" id="qrcode-modal" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div phx-click={Phoenix.LiveView.JS.add_class("hidden", to: "#qrcode-modal")} phx-key="escape" phx-window-keydown={Phoenix.LiveView.JS.add_class("hidden", to: "#qrcode-modal")} class="fixed inset-0 backdrop-blur-md" />
        <div class="flex flex-col items-center p-6 h-full">
          <div class="flex-1" />
          <div class="overflow-y-auto relative w-full max-w-lg bg-white dark:bg-cod-gray rounded-lg shadow-lg p-6 space-y-8">
            <p class="text-xl font-medium text-center">
              Room code: <%= @room_id %>
            </p>
            <div class="flex justify-center items-center">
              <%= Routes.live_url(@socket, __MODULE__, @room_id) |> EQRCode.encode() |> EQRCode.svg() |> raw() %>
            </div>
            <div class="flex justify-center items-center">
              <button phx-click={Phoenix.LiveView.JS.add_class("hidden", to: "#qrcode-modal")} class="btn">Close</button>
            </div>
          </div>
          <div class="flex-1" />
        </div>
      </div>
    </div>
    """
  end

  defp render_question(assigns, question) do
    ~H"""
      <div class="bg-gray-200 dark:bg-gray-600 rounded-lg p-4 space-y-4">
        <div class="space-y-1">
          <p class="font-medium">
            <%= question.attendee.username %>
          </p>
          <p class="text-gray-600 dark:text-gray-200 text-sm">
            <%= question.content %>
          </p>
        </div>

        <div class="flex items-center gap-4">
          <%= if !question.resolved_at do %>
            <button phx-click="resolve" phx-value-question-id={question.id}>
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
            </button>
          <% else %>
            <button phx-click="unresolve" phx-value-question-id={question.id}>
              <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-brand dark:text-brand-200" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
            </button>
          <% end %>

          <div class="flex items-center gap-2">
            <%= if already_vote?(question.question_votes, @maybe_attendee_id) do %>
              <button phx-click="unvote" phx-value-question-id={question.id}>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-brand dark:text-brand-200" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z" />
                </svg>
              </button>
            <% else %>
              <button phx-click="vote" phx-value-question-id={question.id}>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                  <path d="M2 10.5a1.5 1.5 0 113 0v6a1.5 1.5 0 01-3 0v-6zM6 10.333v5.43a2 2 0 001.106 1.79l.05.025A4 4 0 008.943 18h5.416a2 2 0 001.962-1.608l1.2-6A2 2 0 0015.56 8H12V4a2 2 0 00-2-2 1 1 0 00-1 1v.667a4 4 0 01-.8 2.4L6.8 7.933a4 4 0 00-.8 2.4z" />
                </svg>
              </button>
            <% end %>

            <%= Enum.count(question.question_votes) %>
          </div>
        </div>
      </div>
    """
  end
end
