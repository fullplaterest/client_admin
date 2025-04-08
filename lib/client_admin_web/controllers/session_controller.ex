defmodule ClientAdminWeb.SessionController do
  use ClientAdminWeb, :controller

  def create(conn, params) do
  changeset = ClientAdmin.Schemas.User.changeset(params)

  if changeset.valid? do
    %{email: email, cpf: cpf, password: password} = changeset.changes

    case ClientAdmin.MongoRepo.find_one("users", %{"$or" => [%{"email" => email}, %{"cpf" => cpf}]}) do
      nil ->
        password_hash = Argon2.hash_pwd_salt(password)
        doc = %{"email" => email, "cpf" => cpf, "password_hash" => password_hash}

        case ClientAdmin.MongoRepo.insert_one("users", doc) do
          {:ok, %{inserted_id: id}} ->
            user = Map.put(doc, "_id", id)
            {:ok, token, _claims} = ClientAdmin.Guardian.encode_and_sign(user)

            json(conn, %{
              token: token,
              user: %{
                id: BSON.ObjectId.encode!(id),
                email: email,
                cpf: cpf
              }
            })

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
    errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: errors})
  end
  end

  def login(conn, %{"cpf" => cpf, "password" => password}) do
    user = ClientAdmin.MongoRepo.find_one("users", %{"cpf" => cpf})

    cond do
      user == nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "User not found"})

      not Argon2.verify_pass(password, user["password_hash"]) ->
        conn |> put_status(:unauthorized) |> json(%{error: "Invalid credentials"})

      true ->
        {:ok, token, _claims} = ClientAdmin.Guardian.encode_and_sign(user)
        json(conn, %{token: token})
    end
  end
end
