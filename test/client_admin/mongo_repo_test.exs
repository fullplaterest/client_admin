defmodule ClientAdmin.MongoRepoTest do
  use ExUnit.Case

  alias ClientAdmin.MongoRepo

  setup do
    Mongo.delete_many(:mongo, "users", %{})
    :ok
  end

  describe "insert_one/2" do
    test "insere usuário e gera token" do
      {:ok, _res, token} =
        MongoRepo.insert_one("users", %{
          "email" => "teste@example.com",
          "cpf" => "12345678900",
          "password" => "senha123",
          "admin" => "true"
        })

      user = MongoRepo.find_one("users", %{"email" => "teste@example.com"})

      assert user["email"] == "teste@example.com"
      assert user["token"] == token
      assert is_binary(user["password_hash"])
    end

    test "retorna erro se payload estiver inválido" do
      assert {:error, :invalid_payload} = MongoRepo.insert_one("users", %{"cpf" => "12345678900"})
    end
  end

  describe "find_one/2" do
    test "retorna o usuário correspondente ao filtro" do
      Mongo.insert_one(:mongo, "users", %{
        "email" => "a@b.com",
        "cpf" => "123",
        "password_hash" => "abc",
        "admin" => true
      })

      user = MongoRepo.find_one("users", %{"email" => "a@b.com"})

      assert user["email"] == "a@b.com"
      assert user["cpf"] == "123"
    end

    test "retorna nil se não encontrar nenhum documento" do
      user = MongoRepo.find_one("users", %{"email" => "inexistente@x.com"})
      assert user == nil
    end

    test "retorna erro se o filtro for inválido" do
      assert {:error, :invalid_arguments} = MongoRepo.find_one("users", "filtro inválido")
    end
  end

  describe "find_all/1" do
    test "retorna todos os documentos da coleção" do
      Mongo.insert_one(:mongo, "users", %{"email" => "a@b.com"})
      Mongo.insert_one(:mongo, "users", %{"email" => "b@c.com"})

      users = MongoRepo.find_all("users")

      assert length(users) == 2
      emails = Enum.map(users, & &1["email"])
      assert "a@b.com" in emails
      assert "b@c.com" in emails
    end

    test "retorna lista vazia quando a coleção estiver vazia" do
      users = MongoRepo.find_all("users")
      assert users == []
    end

    test "retorna erro se nome da coleção for inválido" do
      assert {:error, :invalid_collection} = MongoRepo.find_all(123)
    end
  end

  test "retorna erro se falhar ao gerar o token" do
    Mimic.expect(ClientAdmin.Guardian, :encode_and_sign, fn _user ->
      {:error, :mocked_error}
    end)

    result =
      MongoRepo.insert_one("users", %{
        "email" => "falhatoken@test.com",
        "cpf" => "00000000000",
        "password" => "123456",
        "admin" => true
      })

    assert {:error, :token_generation_failed, {:error, :mocked_error}} = result
  end

  test "retorna erro se falhar a inserção no Mongo" do
    Mimic.expect(Mongo, :insert_one, fn _conn, _collection, _doc ->
      {:error, :mongo_insert_failed}
    end)

    result =
      MongoRepo.insert_one("users", %{
        "email" => "fail@insert.com",
        "cpf" => "00000000001",
        "password" => "abc123",
        "admin" => true
      })

    assert result == {:error, :mongo_insert_failed}
  end
end
