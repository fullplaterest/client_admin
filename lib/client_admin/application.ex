defmodule ClientAdmin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ClientAdminWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:client_admin, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ClientAdmin.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ClientAdmin.Finch},
      # Start a worker by calling: ClientAdmin.Worker.start_link(arg)
      # {ClientAdmin.Worker, arg},
      # Start to serve requests, typically the last entry
      {Mongo,
       url:
         Application.get_env(
           :client_admin,
           :mongo_url,
           "mongodb://localhost:27017/client_admin_dev"
         ),
       name: :mongo,
       connect: :direct},
      ClientAdminWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
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
