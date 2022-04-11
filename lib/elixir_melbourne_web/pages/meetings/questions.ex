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
    Phoenix.PubSub.subscribe(ElixirMelbourne.PubSub, topic)

    maybe_attendee_id = Map.get(params, "attendee_id", nil)

    if maybe_attendee_id do
      attendee_id = maybe_attendee_id

      Presence.track(
        self(),
        topic,
        attendee_id,
        %{}
      )
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

  def handle_event("vote", %{"question-id" => question_id}, socket) do
    case Meetings.create_question_vote(%{
           question_id: question_id,
           attendee_id: socket.assigns.maybe_attendee_id
         })
         |> IO.inspect() do
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
        </div>
        <%= if !@maybe_attendee_id do %>
          <div class="fixed inset-0 z-40" aria-labelledby="modal-title" role="dialog" aria-modal="true">
            <div class="fixed inset-0 bg-cod-gray/30 dark:bg-white/30" />
            <div class="flex flex-col items-center p-6 h-full">
              <div class="flex-1" />
              <div class="overflow-y-auto relative w-full max-w-lg bg-white rounded-lg shadow-lg p-6 space-y-8">
                <p class="text-xl font-medium">
                  To join this meeting, you must have a username.
                </p>
                <form phx-hook="SetSession" id="saveUserNameForm">
                  <div class="flex items-end gap-4">
                    <div class="flex-1 min-w-0">
                      <label for="username" class="block text-sm font-medium">Username</label>
                      <div class="mt-1">
                        <input type="text" name="username" id="username" class="input" />
                      </div>
                    </div>
                    <button class="btn" type="submit">Save</button>
                  </div>
                </form>
              </div>
              <div class="flex-1" />
            </div>
          </div>
        <% end %>
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
          <%= for question <- @questions do %>
            <div class={"bg-gray-200 dark:bg-gray-600 rounded-lg p-4 space-y-1"}>
              <p class="font-medium">
                <%= question.attendee.username %>
              </p>
              <p class="text-gray-600 dark:text-gray-200 text-sm">
                <%= question.content %>
              </p>

              <%= if !question.resolved_at do %>
                <button  class="btn bg-blue-500" phx-click="resolve" phx-value-question-id={question.id}>Resolve this question</button>
              <% else %>
                <p> This question has been resolved </p>
              <% end %>

              <%= if already_vote?(question.question_votes, @maybe_attendee_id) do %>
                <button class="btn" phx-click="unvote" phx-value-question-id={question.id}>Unvote</button>
              <% else %>
                <button class="btn" phx-click="vote" phx-value-question-id={question.id}>Vote</button>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
      <h3> People who is in the room: </h3>
      <%= for attendee <- @attendees do %>
        <p><%= attendee.username %></p>
      <% end %>
    """
  end
end
