defmodule ElixirMelbourneWeb.Meetings.Questions do
  @moduledoc """
    Page for QA during meetup
  """
  use ElixirMelbourneWeb, :live_view

  def mount(%{"room_id" => room_id}, params, socket) do
    {:ok,
     socket
     |> assign(:room_id, room_id)
     |> assign(:username, Map.get(params, "username", nil))}
  end

  def render(assigns) do
    ~H"""
      Welcome to room code: <%= @room_id %> (enter this code to invite other to join or share the link directly)
      <%= if !@username do %>
        <form phx-hook="SetSession" id="saveUsername">
          <input name="username">
          <button type="submit">Save Username</button>
        </form>
      <% end %>
    """
  end
end
