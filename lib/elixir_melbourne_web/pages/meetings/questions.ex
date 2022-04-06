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
     |> assign(:room_id, room_id)
     |> assign(:attendee_id, Map.get(params, "attendee_id", nil))
     |> assign(:questions, Meetings.list_questions_by_room_id(room_id))
     |> assign(:changeset, Question.changeset(%Question{}, %{}))}
  end

  def handle_event("submit-question", %{"question" => question}, socket) do
    case Meetings.create_question(question) |> IO.inspect() do
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
      Welcome to room code: <%= @room_id %> (enter this code to invite other to join or share the link directly)
      <%= if !@attendee_id do %>
        <form phx-hook="SetSession" id="saveUserNameForm">
          <input name="username">
          <button type="submit">Save Username</button>
        </form>
      <% end %>
      <.form let={f} for={@changeset} phx-submit="submit-question">
        <%= label f, :your_question, class: "block mb-1 typography-button" %>
        <%= text_input f, :content, phx_debounce: "blur", class: "input" %>
        <%= hidden_input f, :room_id, value: @room_id %>
        <%= hidden_input f, :attendee_id, value: @attendee_id %>
        <button type="submit">Submit</button>
      </.form>
      <%= for question <- @questions do %>
        <div>
          <%= question.content %>
          <%= question.attendee.username %>
        </div>
      <% end %>
    """
  end
end
