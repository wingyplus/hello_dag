defmodule HelloDag.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HelloDagWeb.Telemetry,
      HelloDag.Repo,
      {DNSCluster, query: Application.get_env(:hello_dag, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HelloDag.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: HelloDag.Finch},
      # Start a worker by calling: HelloDag.Worker.start_link(arg)
      # {HelloDag.Worker, arg},
      # Start to serve requests, typically the last entry
      HelloDagWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloDag.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HelloDagWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
