defmodule ClientAdminWeb.AuthErrorHandler do
  import Plug.Conn

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(%{error: "Unauthorized"})
  end
end
