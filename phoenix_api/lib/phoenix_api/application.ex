defmodule PhoenixApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixApiWeb.Telemetry,
      PhoenixApi.Repo,
      {DNSCluster, query: Application.get_env(:phoenix_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixApi.Finch},
      # Start a worker by calling: PhoenixApi.Worker.start_link(arg)
      # {PhoenixApi.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
