defmodule ElixirMelbourneWeb.Meetings.View do
  @moduledoc """
    Page for view single meeting
  """
  use ElixirMelbourneWeb, :live_view


  def handle_event("create_room", _params, socket) do
    # Generate a 6 digit room number
    room_id = generate_room_id()
    {:noreply,
    push_redirect(socket, to: Routes.live_path(socket, ElixirMelbourneWeb.Meetings.Questions, room_id))}
  end

  def handle_event("join_room", %{"room_id" => room_id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, ElixirMelbourneWeb.Meetings.Questions, room_id))}
  end

  def render(assigns) do
    ~H"""
      <button phx-click="create_room">create new room</button>
      <form phx-submit="join_room">
        <input type="text" name="room_id">
        <button type="submit">join new room</button>
      </form>
    """
  end

  defp generate_room_id() do
    room_id = ElixirMelbourne.Helper.Randomizer.randomizer(6)
    if ElixirMelbourne.Meetings.room_id_exists?(room_id) do
      generate_room_id()
    else
      room_id
    end
  end
end
