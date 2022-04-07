defmodule ElixirMelbourneWeb.Meetings.View do
  @moduledoc """
    Page for view single meeting
  """
  use ElixirMelbourneWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:active_link, "meetings")

    {:ok, socket}
  end

  def handle_event("create_room", _params, socket) do
    # Generate a 6 digit room number
    room_id = generate_room_id()

    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, ElixirMelbourneWeb.Meetings.Questions, room_id)
     )}
  end

  def handle_event("join_room", %{"room_id" => room_id}, socket) do
    {:noreply,
     push_redirect(socket,
       to: Routes.live_path(socket, ElixirMelbourneWeb.Meetings.Questions, room_id)
     )}
  end

  def render(assigns) do
    ~H"""
      <div class="space-y-8">
        <button phx-click="create_room" class="btn">Create a new room</button>
        <div class="h-px bg-gray-200 dark:bg-gray-600" />
        <form phx-submit="join_room">
          <div class="space-y-4">
            <div>
              <label for="room_id" class="block text-sm font-medium">Room ID</label>
              <div class="mt-1">
                <input type="text" name="room_id" id="room_id" class="input" placeholder="IbpdAi" />
              </div>
            </div>
            <button class="btn" type="submit">Join</button>
          </div>
        </form>
      </div>
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
