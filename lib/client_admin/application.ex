defmodule ClientAdmin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    IO.inspect(Application.fetch_env!(:client_admin, :mongo_config))

    children = [
      ClientAdminWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:client_admin, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ClientAdmin.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ClientAdmin.Finch},
      {Mongo, Application.fetch_env!(:client_admin, :mongo_config)},
      ClientAdminWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: ClientAdmin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClientAdminWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
