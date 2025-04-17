defmodule ClientAdmin.Order.Handler do
  use Tesla

  alias ClientAdmin.User.Handler, as: UserHandler

  @base_url "http://app:4001/api/order"
  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.JSON

  def create(params, user) do
    with {:ok, user} <- UserHandler.user_clean(user),
         params <- Map.put(params, "user_info", user) do
      case post("/", params) do
        {:ok, %Tesla.Env{status: 201, body: body}} ->
          {:ok, body}

        {:ok, %Tesla.Env{status: status, body: body}} ->
          {:error, %{status: status, response: body}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def create(params) do
    case post("/", params) do
      {:ok, %Tesla.Env{status: 201, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_one(params) do
    case get("/#{params["id"]}") do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def list(params) do
    case get("/orders/?page=#{params["page"]}&page_size=#{params["page_size"]}") do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def update(params) do
    case put("/#{params["id"]}", params) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, %{status: status, response: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
