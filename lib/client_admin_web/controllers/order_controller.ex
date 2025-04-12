defmodule ClientAdminWeb.OrderController do
  use ClientAdminWeb, :controller

  require Logger

  alias ClientAdmin.Order.Handler, as: OrderHandler

  action_fallback(ClientAdminWeb.FallbackController)

  plug :put_view, json: ClientAdminWeb.Jsons.OrderJson

  def create(conn, params) do
    with user <- Guardian.Plug.current_resource(conn),
         {:ok, order} <- OrderHandler.create(params, user) do
      conn
      |> put_status(:created)
      |> render(:order, loyalt: false, order: order, status: :created)
    else
      nil ->
        {:ok, order} = OrderHandler.create(params)

        conn
        |> put_status(:created)
        |> render(:order, loyalt: false, order: order, status: :created)
    end
  end

  def list(conn, params) do
    with {:ok, order} <- OrderHandler.list(params) do
      conn
      |> put_status(:ok)
      |> render(:order_list, loyalt: false, order: order)
    end
  end

  def update(conn, params) do
    with user <- Guardian.Plug.current_resource(conn),
         {:ok, order} <- OrderHandler.update(params) do
      conn
      |> put_status(:ok)
      |> render(:order, loyalt: false, order: order, status: :updated)
    end
  end
end
