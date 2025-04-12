defmodule ClientAdminWeb.SessionControllerTest do
  use ClientAdminWeb.ConnCase, async: true

  setup do
    Mongo.delete_many(:mongo, "users", %{})
    :ok
  end

  describe "create/2" do
    test "cria usuário se ainda não existir", %{conn: conn} do
      params = %{
        "email" => "test@email.com",
        "cpf" => "12345678900",
        "password" => "Senha123@teste",
        "admin" => true
      }

      conn = post(conn, "/api/session", params)

      json = json_response(conn, 200)
      assert is_binary(json["token"])
      assert json["user"]["email"] == "test@email.com"
      assert json["user"]["cpf"] == "12345678900"
    end

    test "retorna 409 se usuário já existir", %{conn: conn} do
      params = %{
        "email" => "test@email.com",
        "cpf" => "12345678900",
        "password" => "Senha123@teste",
        "admin" => true
      }

      post(conn, "/api/session", params)

      conn =
        post(conn, "/api/session", %{
          "email" => "test@email.com",
          "cpf" => "12345678900",
          "password" => "Senha123@teste",
          "admin" => true
        })

      assert json_response(conn, 409)["error"] == "Usuário com este CPF ou e-mail já existe"
    end

    test "retorna erro se dados forem inválidos", %{conn: conn} do
      conn = post(conn, "/api/session", %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "login/2" do
    setup do
      Mongo.delete_many(:mongo, "users", %{})

      {:ok, _, _token} =
        ClientAdmin.MongoRepo.insert_one("users", %{
          "email" => "test@email.com",
          "cpf" => "12345678900",
          "password" => "senha123",
          "admin" => true
        })

      :ok
    end

    test "login com sucesso", %{conn: conn} do
      conn =
        post(conn, "/api/session/login", %{
          "cpf" => "12345678900",
          "password" => "senha123"
        })

      assert %{"token" => token} = json_response(conn, 200)
      assert is_binary(token)
    end

    test "erro ao logar com CPF inexistente", %{conn: conn} do
      conn =
        post(conn, "/api/session/login", %{
          "cpf" => "00000000000",
          "password" => "senha123"
        })

      assert json_response(conn, 401)["error"] == "User not found"
    end

    test "erro ao logar com senha inválida", %{conn: conn} do
      conn =
        post(conn, "/api/session/login", %{
          "cpf" => "12345678900",
          "password" => "senha_errada"
        })

      assert json_response(conn, 401)["error"] == "Invalid credentials"
    end
  end

  test "retorna erro 500 se falhar ao gerar token", %{conn: conn} do
    Mimic.expect(ClientAdmin.MongoRepo, :find_one, fn "users", _ -> nil end)

    Mimic.expect(ClientAdmin.MongoRepo, :insert_one, fn "users", _params ->
      {:error, :token_generation_failed, :simulated_failure}
    end)

    conn =
      post(conn, "/api/session", %{
        "email" => "tokenfail@email.com",
        "cpf" => "99999999999",
        "password" => "Senha123@teste",
        "admin" => true
      })

    assert json_response(conn, 500)["error"] == "Erro ao gerar token"
  end

  test "retorna erro 500 se falhar ao criar usuário", %{conn: conn} do
    Mimic.expect(ClientAdmin.MongoRepo, :find_one, fn "users", _ -> nil end)

    Mimic.expect(ClientAdmin.MongoRepo, :insert_one, fn "users", _params ->
      {:error, :mongo_crash}
    end)

    conn =
      post(conn, "/api/session", %{
        "email" => "crash@email.com",
        "cpf" => "88888888888",
        "password" => "Senha123@teste",
        "admin" => true
      })

    assert json_response(conn, 500)["error"] == "Erro ao criar usuário"
  end
end
