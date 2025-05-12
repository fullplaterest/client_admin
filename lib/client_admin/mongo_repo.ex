defmodule ClientAdmin.MongoRepo do
  def insert_one(collection, %{
        "email" => email,
        "cpf" => cpf,
        "password" => password,
        "admin" => admin
      }) do
    password_hash = Argon2.hash_pwd_salt(password)

    insert_one(collection, %{
      "email" => email,
      "cpf" => cpf,
      "password_hash" => password_hash,
      "admin" => admin
    })
  end

  def insert_one(collection, %{
        "email" => email,
        "cpf" => cpf,
        "password_hash" => password_hash,
        "admin" => admin
      }) do
    doc = %{"email" => email, "cpf" => cpf, "password_hash" => password_hash, "admin" => admin}

    case Mongo.insert_one(:mongo, collection, doc) do
      {:ok, %{inserted_id: id} = result} ->
        user = Map.put(doc, "_id", id)

        case ClientAdmin.Guardian.encode_and_sign(user) do
          {:ok, token, _claims} ->
            Mongo.update_one(
              :mongo,
              collection,
              %{"_id" => id},
              %{"$set" => %{"token" => token}},
              []
            )

            {:ok, result, token}

          error ->
            {:error, :token_generation_failed, error}
        end

      error ->
        error
    end
  end

  def insert_one(_collection, _), do: {:error, :invalid_payload}

  def find_one(collection, filter) when is_binary(collection) and is_map(filter) do
    Mongo.find_one(:mongo, collection, filter)
  end

  def find_one(_, _), do: {:error, :invalid_arguments}

  def find_all(collection) when is_binary(collection) do
    Mongo.find(:mongo, collection, %{}) |> Enum.to_list()
  end

  def find_all(_), do: {:error, :invalid_collection}
end
