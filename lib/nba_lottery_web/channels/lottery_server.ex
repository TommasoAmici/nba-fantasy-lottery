defmodule NbaLotteryWeb.LotteryServer do
  use GenServer

  @name :lottery_server
  @pubsub NbaLottery.PubSub
  @topic "lottery"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  @teams [
    %{name: "San Antonio Gramsci", logo: "/images/gramsci.jpg", num_balls: 140, odds: {0, 140}},
    %{name: "Bristol Giabbies", logo: "/images/giabbies.png", num_balls: 140, odds: {140, 280}},
    %{
      name: "Fidati del processo",
      logo: "/images/processo.jpg",
      num_balls: 105,
      odds: {280, 385}
    },
    %{
      name: "Big Taberna Brand",
      logo: "/images/big_taberna.jpg",
      num_balls: 75,
      odds: {385, 460}
    },
    %{
      name: "Queensbridge's Burglars",
      logo: "/images/queens.jpg",
      num_balls: 45,
      odds: {460, 505}
    },
    %{
      name: "Porta Palazzo Trailblazers",
      logo: "/images/porta_palazzo.jpg",
      num_balls: 20,
      odds: {505, 525}
    },
    %{
      name: "Cambiano Saldators",
      logo: "/images/cambiano.jpg",
      num_balls: 10,
      odds: {525, 535}
    },
    %{name: "Kansas City Shufflers", logo: "/images/kansas.jpg", num_balls: 5, odds: {535, 540}}
  ]

  def init(_state) do
    {:ok, %{teams: @teams, extracted: []}}
  end

  def handle_call(:reset, _from, _state) do
    state = %{teams: @teams, extracted: []}
    Phoenix.PubSub.broadcast(@pubsub, @topic, {:reset, state})
    {:reply, state, state}
  end

  def handle_call(:get_teams, _from, state) do
    {:reply, state.teams, state}
  end

  def handle_call(:get_extracted, _from, state) do
    {:reply, state.extracted, state}
  end

  def handle_call(:extract, _from, state) do
    extracted_map = Map.new(state.extracted, fn team -> {team.name, team} end)
    new_extracted = extract_next(extracted_map, state.teams)
    Phoenix.PubSub.broadcast(@pubsub, @topic, {:extracted, new_extracted})
    extracted = [new_extracted | state.extracted]
    state = %{state | extracted: extracted}
    {:reply, state, state}
  end

  defp extract_next(extracted_map, teams) do
    random_number = :rand.uniform(540)

    team =
      teams
      |> Enum.find(fn %{odds: {min_odd, max_odd}} ->
        random_number >= min_odd and random_number < max_odd
      end)

    case Map.get(extracted_map, team.name) do
      nil -> team
      _ -> extract_next(extracted_map, teams)
    end
  end

  def extract_next() do
    GenServer.call(@name, :extract)
  end

  def reset() do
    GenServer.call(@name, :reset)
  end

  def get_teams() do
    GenServer.call(@name, :get_teams)
  end

  def get_extracted() do
    GenServer.call(@name, :get_extracted)
  end
end
