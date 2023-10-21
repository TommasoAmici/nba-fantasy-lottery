defmodule NbaLotteryWeb.LotteryLive do
  use NbaLotteryWeb, :live_view

  @pubsub NbaLottery.PubSub
  @topic "lottery"

  def subscribe() do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      subscribe()
    end

    teams = NbaLotteryWeb.LotteryServer.get_teams()

    extracted = NbaLotteryWeb.LotteryServer.get_extracted()

    random_balls =
      teams
      |> Enum.map(fn team -> List.duplicate(team.logo, team.num_balls) end)
      |> List.flatten()
      |> Enum.shuffle()

    {:ok, assign(socket, teams: teams, extracted: extracted),
     temporary_assigns: [random_balls: random_balls]}
  end

  def team_card(assigns) do
    ~H"""
    <article class="flex items-center gap-4">
      <img src={@logo} width="48" class="object-cover h-12 w-12 rounded-full" />
      <strong><%= @name %></strong>
    </article>
    """
  end

  def handle_event("extract", _unsigned_params, socket) do
    NbaLotteryWeb.LotteryServer.extract_next()
    {:noreply, socket}
  end

  def handle_event("reset", _unsigned_params, socket) do
    NbaLotteryWeb.LotteryServer.reset()
    {:noreply, socket}
  end

  def handle_info({:extracted, extracted}, socket) do
    {:noreply, assign(socket, extracted: [extracted | socket.assigns.extracted])}
  end

  def handle_info({:reset, %{teams: teams, extracted: extracted}}, socket) do
    {:noreply, assign(socket, extracted: extracted, teams: teams)}
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col">
      <div class="grid lg:grid-cols-8 h-full">
        <aside class="lg:col-span-2 bg-neutral-100 p-4">
          <img src="/images/logo.png" width="200" />
          <ul class="flex flex-col gap-2 mt-8">
            <li :for={team <- @teams}>
              <div class="flex justify-between items-center">
                <.team_card name={team.name} logo={team.logo} />
                <span class="text-neutral-700"><%= team.num_balls %></span>
              </div>
            </li>
          </ul>
        </aside>
        <main class="lg:col-span-6 h-full relative">
          <div class="min-h-[200px]">
            <div :if={length(@teams) != length(@extracted)} class="flex justify-center mt-8">
              <div class="flex flex-col">
                <button
                  phx-click="extract"
                  class="bg-[#1c428a] hover:opacity-90 p-4 text-lg rounded-md text-white font-semibold uppercase"
                >
                  Estrai
                </button>
                <button phx-click="reset" class="text-[#1c428a] hover:opacity-90 p-4 text-md">
                  Reset
                </button>
              </div>
            </div>

            <section
              :if={length(@extracted) > 0}
              class="flex justify-center flex-col items-center my-12"
            >
              <h2 class="font-semibold text-3xl">Vincitori</h2>
              <ul class="flex flex-col gap-2">
                <li :for={team <- @extracted |> Enum.reverse()}>
                  <.team_card name={team.name} logo={team.logo} />
                </li>
              </ul>
            </section>
          </div>

          <div class="w-full overflow-hidden absolute bottom-0">
            <div class="flex animate-slide">
              <%= for logo <- @random_balls do %>
                <img
                  src={logo}
                  width="32"
                  class="object-cover animate-slow-spin h-8 w-8 rounded-full"
                />
              <% end %>
            </div>
          </div>
        </main>
      </div>
    </div>
    """
  end
end
