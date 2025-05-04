defmodule ClientAdmin.Product.Handler do
  @behaviour ClientAdmin.Product.HandlerBehaviour
  use Tesla

  alias ClientAdmin.User.Handler, as: UserHandler

  @base_url "http://app:4001/api/product"
  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON

  defp adapter,
    do: Application.get_env(:client_admin, __MODULE__, [])[:adapter] || Tesla.Adapter.Hackney

  defp client, do: Tesla.client([], adapter())

  @spec create(map(), nil | maybe_improper_list() | map()) :: {:error, any()} | {:ok, any()}
  def create(params, user) do
    with {:ok, user} <- UserHandler.user_clean(user),
         params <- Map.put(params, "user_info", user) do
      case post(client(), "", params) do
        {:ok, %Tesla.Env{status: 201, body: body}} ->
          {:ok, body}

        {:ok, %Tesla.Env{status: status, body: body}} ->
          {:error, %{status: status, response: body}}
      end
    end
  end

  def list(params) do
    case get(client(), "/#{params["type"]}") do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}
    end
  end

  def update(params) do
    case put("/#{params["id"]}", params) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}
    end
  end
end
