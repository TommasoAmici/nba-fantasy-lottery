defmodule NbaLottery.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NbaLotteryWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:nba_lottery, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NbaLottery.PubSub},
      # Start a worker by calling: NbaLottery.Worker.start_link(arg)
      # {NbaLottery.Worker, arg},
      # Start to serve requests, typically the last entry
      NbaLotteryWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NbaLottery.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NbaLotteryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end