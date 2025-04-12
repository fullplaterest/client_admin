defmodule ClientAdminWeb.OrderController do
  use ClientAdminWeb, :controller

  require Logger

  alias ClientAdmin.Order.Handler, as: OrderHandler

  action_fallback(ClientAdminWeb.FallbackController)

  plug :put_view, json: ClientAdminWeb.Jsons.OrderJson

  def create(conn, params) do
    with nil <- Guardian.Plug.current_resource(conn),
         {:ok, order} <- OrderHandler.create(params) do
      conn
      |> put_status(:created)
      |> render(:order, loyalt: false, order: order, status: :created)
    else
      {:error, reason} ->
        {:error, reason}

      user ->
        with {:ok, order} <- OrderHandler.create(params, user) do
          conn
          |> put_status(:created)
          |> render(:order, loyalt: false, order: order, status: :created)
        end
    end
  end

  def get(conn, params) do
    with {:ok, order} <- OrderHandler.get_one(params) do
      conn
      |> put_status(:ok)
      |> render(:order, loyalt: false, order: order, status: :show)
    end
  end

  def list(conn, params) do
    with user <- Guardian.Plug.current_resource(conn),
         {:ok, order} <- OrderHandler.list(params, user) do
      conn
      |> put_status(:ok)
      |> render(:order_list, loyalt: false, order: order)
    end
  end

  def list_all(conn, params) do
    with user <- Guardian.Plug.current_resource(conn),
         true <- validate_admin(user),
         {:ok, order} <- OrderHandler.list_all(params) do
      conn
      |> put_status(:ok)
      |> render(:order_list, loyalt: false, order: order)
    end
  end

  def update(conn, params) do
    with user <- Guardian.Plug.current_resource(conn),
         true <- validate_admin(user),
         {:ok, order} <- OrderHandler.update(params) do
      conn
      |> put_status(:ok)
      |> render(:order, loyalt: false, order: order, status: :updated)
    end
  end

  defp validate_admin(%{"admin" => true}), do: true
  defp validate_admin(_), do: {:error, :unauthorized}
end
