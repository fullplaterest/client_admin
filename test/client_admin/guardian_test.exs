defmodule ClientAdmin.GuardianTest do
  use ExUnit.Case, async: true

  alias ClientAdmin.Guardian

  @collection "users"

  setup do
    Mongo.delete_many(:mongo, @collection, %{})

    user = %{
      "email" => "guardian@test.com",
      "cpf" => "12345678900",
      "password_hash" => Argon2.hash_pwd_salt("senha123")
    }

    {:ok, %{inserted_id: id}} = Mongo.insert_one(:mongo, @collection, user)
    user = Map.put(user, "_id", id)

    {:ok, user: user}
  end

  describe "subject_for_token/2" do
    test "retorna o id do usuário como subject", %{user: user} do
      {:ok, sub} = Guardian.subject_for_token(user, %{})
      assert sub == BSON.ObjectId.encode!(user["_id"])
    end
  end

  describe "resource_from_claims/1" do
    test "retorna o usuário se encontrado", %{user: user} do
      claims = %{"sub" => BSON.ObjectId.encode!(user["_id"])}
      {:ok, found_user} = Guardian.resource_from_claims(claims)

      assert found_user["email"] == user["email"]
      assert found_user["cpf"] == user["cpf"]
    end

    test "retorna erro se usuário não for encontrado" do
      claims = %{
        "sub" => BSON.ObjectId.encode!(%BSON.ObjectId{value: :crypto.strong_rand_bytes(12)})
      }

      assert {:error, :not_found} = Guardian.resource_from_claims(claims)
    end
  end
end
