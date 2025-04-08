defmodule ClientAdminWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :client_admin,
    module: ClientAdmin.Guardian,
    error_handler: ClientAdminWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
