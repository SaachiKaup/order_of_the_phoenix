defmodule OrderOfThePhoenix.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OrderOfThePhoenixWeb.Telemetry,
      OrderOfThePhoenix.Repo,
      {DNSCluster, query: Application.get_env(:order_of_the_phoenix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: OrderOfThePhoenix.PubSub},
      # Start a worker by calling: OrderOfThePhoenix.Worker.start_link(arg)
      # {OrderOfThePhoenix.Worker, arg},
      # Start to serve requests, typically the last entry
      OrderOfThePhoenixWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: OrderOfThePhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    OrderOfThePhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
