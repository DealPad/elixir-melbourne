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
    <div class="space-y-20 pt-14">
      <div>
        <h1 class="mb-4 text-4xl font-extrabold text-cod-gray dark:text-white">Welcome to elixir_melbourne!</h1>
        <p class="text-lg font-medium opacity-60 text-cod-gray dark:text-white">
          For anyone using or interested in Elixir (with a healthy side dose of Erlang). Welcome to Elixir coders of all levels: dabblers; everyday users; pros.
        </p>
      </div>
      <div class="space-y-6">
        <h2 class="text-2xl font-bold text-cod-gray dark:text-white">Contributors</h2>
        <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 items-start gap-4">
          <div class="flex flex-col justify-center items-center gap-2">
            <img class="rounded-full h-20 w-20" src="https://images.ctfassets.net/ye2xsl4yl17z/dTDpgHMXkKCkHikxoa6qI/82eb151b027c2155b7f90cda477e084a/Jimmy.jpg?w=80&h=80" />
            <div>
              <p class="text-cod-gray dark:text-white font-medium text-center">Jimmy Qiu</p>
              <p class="text-cod-gray/60 dark:text-white/60 text-center">Head of Engineering at Fresh Equities</p>
            </div>
          </div>
          <div class="flex flex-col justify-center items-center gap-2">
            <img class="rounded-full h-20 w-20" src="https://images.ctfassets.net/ye2xsl4yl17z/jm9M7J4Bxev6V4thbuQL0/95ff958415567116ed601be68fd474f3/William.jpg?w=80&h=80" />
            <div>
              <p class="text-cod-gray dark:text-white font-medium text-center">William Kurniawan</p>
              <p class="text-cod-gray/60 dark:text-white/60 text-center">Software Engineer at Fresh Equities</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
