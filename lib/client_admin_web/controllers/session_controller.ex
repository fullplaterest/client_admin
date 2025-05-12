defmodule ClientAdminWeb.SessionController do
  use ClientAdminWeb, :controller

  def create(conn, params) do
    changeset = ClientAdmin.Schemas.User.changeset(params)

    if changeset.valid? do
      %{email: email, cpf: cpf, password: password, admin: admin} = changeset.changes

      case ClientAdmin.MongoRepo.find_one("users", %{
             "$or" => [%{"email" => email}, %{"cpf" => cpf}]
           }) do
        nil ->
          case ClientAdmin.MongoRepo.insert_one("users", %{
                 "email" => email,
                 "cpf" => cpf,
                 "password" => password,
                 "admin" => admin
               }) do
            {:ok, %{inserted_id: id}, token} ->
              json(conn, %{
                token: token,
                user: %{
                  id: BSON.ObjectId.encode!(id),
                  email: email,
                  cpf: cpf,
                  admin: admin
                }
              })

            {:error, :token_generation_failed, reason} ->
              conn
              |> put_status(:internal_server_error)
              |> json(%{error: "Erro ao gerar token", reason: inspect(reason)})

            {:error, reason} ->
              conn
              |> put_status(:internal_server_error)
              |> json(%{error: "Erro ao criar usuário", reason: inspect(reason)})
          end

        _ ->
          conn
          |> put_status(:conflict)
          |> json(%{error: "Usuário com este CPF ou e-mail já existe"})
      end
    else
      errors =
        Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} ->
          msg
        end)

      conn
      |> put_status(:unprocessable_entity)
      |> json(%{errors: errors})
    end
  end

  def login(conn, %{"cpf" => cpf, "password" => password}) do
    case ClientAdmin.MongoRepo.find_one("users", %{"cpf" => cpf}) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "User not found"})

      user ->
        case Argon2.verify_pass(password, user["password_hash"]) do
          true ->
            {:ok, token, _claims} = ClientAdmin.Guardian.encode_and_sign(user)
            json(conn, %{token: token})

          false ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Invalid credentials"})
        end
    end
  end
end
