defmodule ClientAdmin.Order.Handler do
  @behaviour ClientAdmin.Order.HandlerBehavior
  use Tesla

  alias ClientAdmin.User.Handler, as: UserHandler

  @base_url "http://app:4001/api/order"
  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON

  defp adapter,
    do: Application.get_env(:client_admin, __MODULE__, [])[:adapter] || Tesla.Adapter.Hackney

  defp client, do: Tesla.client([], adapter())

  def create(params, user) do
    with {:ok, user} <- UserHandler.user_clean(user),
         params <- Map.put(params, "user_info", user) do
      case post(client(), "/", params) do
        {:ok, %Tesla.Env{status: 201, body: body}} ->
          {:ok, body}

        {:ok, %Tesla.Env{status: status, body: body}} ->
          {:error, %{status: status, response: body}}
      end
    end
  end

  def create(params) do
    case post(client(), "/", params) do
      {:ok, %Tesla.Env{status: 201, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}
    end
  end

  def get_one(params) do
    case get(client(), "/#{params["id"]}") do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}
    end
  end

  def list(params) do
    case get(client(), "/orders/?page=#{params["page"]}&page_size=#{params["page_size"]}") do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}
    end
  end

  def update(params) do
    case put(client(), "/#{params["id"]}", params) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}
    end
  end
end
