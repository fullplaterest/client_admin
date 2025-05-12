defmodule ClientAdminWeb.ProductController do
  use ClientAdminWeb, :controller

  require Logger

  alias ClientAdmin.Product.Handler, as: ProductHandler

  action_fallback(ClientAdminWeb.FallbackController)

  plug :put_view, json: ClientAdminWeb.Jsons.ProductJson

  def create(conn, params) do
    with user <- Guardian.Plug.current_resource(conn),
         true <- validate_admin(user),
         {:ok, product} <- ProductHandler.create(params, user) do
      conn
      |> put_status(:created)
      |> render(:product, loyalt: false, product: product, status: :created)
    end
  end

  def list(conn, params) do
    with {:ok, product} <- ProductHandler.list(params) do
      conn
      |> put_status(:ok)
      |> render(:product_list, loyalt: false, product: product)
    end
  end

  def update(conn, params) do
    with user <- Guardian.Plug.current_resource(conn),
         true <- validate_admin(user),
         {:ok, product} <- ProductHandler.update(params) do
      conn
      |> put_status(:ok)
      |> render(:product, loyalt: false, product: product, status: :updated)
    end
  end

  defp validate_admin(%{"admin" => true}), do: true
  defp validate_admin(_), do: {:error, :unauthorized}
end
