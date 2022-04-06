defmodule ElixirMelbourneWeb.Meetings.Questions do
  @moduledoc """
    Page for QA during meetup
  """
  use ElixirMelbourneWeb, :live_view

  def mount(%{"room_id" => room_id },b, socket) do
    {:ok, socket
   |> assign(:room_id, room_id)}
  end

  def render(assigns) do
    ~H"""
      Welcome to room code: <%= @room_id %> (enter this code to invite other to join or share the link directly)
    """
  end
end
