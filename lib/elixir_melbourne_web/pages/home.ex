defmodule ElixirMelbourneWeb.HomePage do
  use ElixirMelbourneWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:active_link, "home")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    """
  end
end
