defmodule TplPhoenixPgK8sTilt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TplPhoenixPgK8sTiltWeb.Telemetry,
      TplPhoenixPgK8sTilt.Repo,
      {DNSCluster, query: Application.get_env(:tpl_phoenix_pg_k8s_tilt, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TplPhoenixPgK8sTilt.PubSub},
      # Start a worker by calling: TplPhoenixPgK8sTilt.Worker.start_link(arg)
      # {TplPhoenixPgK8sTilt.Worker, arg},
      # Start to serve requests, typically the last entry
      TplPhoenixPgK8sTiltWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TplPhoenixPgK8sTilt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TplPhoenixPgK8sTiltWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
