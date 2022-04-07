defmodule ElixirMelbourneWeb.Meetings.Questions do
  @moduledoc """
    Page for QA during meetup
  """
  use ElixirMelbourneWeb, :live_view
  alias ElixirMelbourne.Meetings.Question
  alias ElixirMelbourne.Meetings

  def mount(%{"room_id" => room_id}, params, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(ElixirMelbourne.PubSub, "room: #{room_id}")
    end

    {:ok,
     socket
     |> assign(:active_link, "meetings")
     |> assign(:attendee_id, Map.get(params, "attendee_id", nil))
     |> assign(:changeset, Question.changeset(%Question{}, %{}))
     |> assign(:questions, Meetings.list_questions_by_room_id(room_id))
     |> assign(:room_id, room_id)}
  end

  def handle_event("submit-question", %{"question" => question}, socket) do
    case question
         |> Map.put("attendee_id", socket.assigns.attendee_id)
         |> Map.put("room_id", socket.assigns.room_id)
         |> Meetings.create_question()
         |> IO.inspect() do
      {:ok, %Question{room_id: room_id}} ->
        Phoenix.PubSub.broadcast(ElixirMelbourne.PubSub, "room: #{room_id}", :new_question)
        {:noreply, socket |> assign(:changeset, Question.changeset(%Question{}, %{}))}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_info(:new_question, %{assigns: %{room_id: room_id}} = socket) do
    {:noreply,
     socket
     |> assign(%{
       questions: Meetings.list_questions_by_room_id(room_id)
     })}
  end

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
        <%= if !@attendee_id do %>
          <form phx-hook="SetSession" id="saveUserNameForm">
            <div class="flex items-end gap-4">
              <div>
                <label for="username" class="block text-sm font-medium">Username</label>
                <div class="mt-1">
                  <input type="text" name="username" id="username" class="input" />
                </div>
              </div>
              <button class="btn" type="submit">Save</button>
            </div>
          </form>
        <% end %>
        <.form let={f} for={@changeset} phx-submit="submit-question" class="border border-gray-200 dark:border-gray-600 rounded-lg p-4">
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
            <div class="bg-gray-200 dark:bg-gray-600 rounded-lg p-4 space-y-1">
              <p class="font-medium">
                <%= question.attendee.username %>
              </p>
              <p class="text-gray-600 dark:text-gray-200 text-sm">
                <%= question.content %>
              </p>
            </div>
          <% end %>
        </div>
      </div>
    """
  end
end
