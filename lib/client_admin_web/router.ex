defmodule ClientAdminWeb.Router do
  use ClientAdminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ClientAdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug ClientAdminWeb.AuthPipeline
  end

  scope "/", ClientAdminWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", ClientAdminWeb do
    pipe_through :api

    post "/session", SessionController, :create
    post "/session/login", SessionController, :login
  end

  scope "/api/product", ClientAdminWeb do
    pipe_through [:api, :auth]

    post "/", ProductController, :create
    put "/:id", ProductController, :update
    delete "/:id", ProductController, :delete
  end

  scope "/api/open/product", ClientAdminWeb do
    pipe_through [:api]

    get "/:type", ProductController, :list
  end

  scope "/api/order", FullPlateWeb do
    pipe_through [:api, :auth]

    post "/", OrderController, :create
    get "/", OrderController, :get_orders
    get "/orders", OrderController, :list_orders
    put "/:id", OrderController, :update_status
  end

  scope "/api/open/order", FullPlateWeb do
    pipe_through [:api]

    post "/", OrderController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", ClientAdminWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:client_admin, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ClientAdminWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
