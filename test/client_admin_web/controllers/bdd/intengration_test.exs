defmodule ClientAdminWeb.Bdd.IntengrationTest do
  use ClientAdminWeb.ConnCase, async: false
  import Mox

  setup :verify_on_exit!

  setup do
    Mongo.delete_many(:mongo, "users", %{})
    :ok
  end

  describe "Behavior-Driven Development" do
    test "Cria um usuario admin, registra um produto, registra um usario nao admin e faz um pedido, nao admin verifica o pedido",
         %{conn: conn} do
      # Cria usuário admin e faz login
      user_admin = %{
        "email" => "test@email.com",
        "cpf" => "12345678900",
        "password" => "Senha123@teste",
        "admin" => true
      }

      conn_admin = post(conn, "/api/session", user_admin)

      json_admin = json_response(conn_admin, 200)
      assert is_binary(json_admin["token"])
      assert json_admin["user"]["email"] == "test@email.com"
      assert json_admin["user"]["cpf"] == "12345678900"

      # Faz requisição autenticada para criar produto
      product = %{
        "product_name" => "milkshake morango doce azedo",
        "description" => "sorvete + leite + morango",
        "type" => "sobremesa",
        "price" => "11",
        "picture" => "www.picture_web.com"
      }

      auth_conn_admin =
        conn_admin
        |> recycle()
        |> put_req_header("authorization", "Bearer #{json_admin["token"]}")

      # cria um produto com sucesso
      Tesla.Mock.mock(fn
        %{method: :post, url: "http://app:4001/api/product"} ->
          %Tesla.Env{
            status: 201,
            body: %{
              "id" => Ecto.UUID.generate(),
              "product_name" => "milkshake morango doce azedo",
              "description" => "sorvete + leite + morango",
              "price" => "11"
            }
          }
      end)

      conn_product = post(auth_conn_admin, "/api/product", product)
      json_product = json_response(conn_product, 201)
      assert json_product["product_name"] == "milkshake morango doce azedo"
      assert json_product["description"] == "sorvete + leite + morango"
      assert json_product["status"] == "created"

      # cria um usuario nao admin para fazer um pedido
      user = %{
        "email" => "test_not_admin@email.com",
        "cpf" => "12345678908",
        "password" => "Senha123@teste",
        "admin" => false
      }

      conn_unique = post(conn, "/api/session", user)

      json_not_admin = json_response(conn_unique, 200)
      assert is_binary(json_not_admin["token"])
      assert json_not_admin["user"]["email"] == "test_not_admin@email.com"
      assert json_not_admin["user"]["cpf"] == "12345678908"

      # lista os produtos para pegar o id e fazer o pedido
      url = "http://app:4001/api/product/sobremesa"

      Tesla.Mock.mock(fn
        %{method: :get, url: ^url} ->
          %Tesla.Env{
            status: 200,
            body: [
              %{
                "id" => json_product["id"],
                "product_name" => "milkshake morango doce azedo",
                "description" => "sorvete + leite + morango",
                "price" => "11"
              }
            ]
          }
      end)

      conn_products = get(conn, "/api/open/product/sobremesa")
      json = json_response(conn_products, 200)
      assert length(json) == 1

      # Faz requisição autenticada para criar o pedido
      order = %{
        "order" => [json_not_admin["user"]["id"]]
      }

      # cria um pedido com sucesso
      Tesla.Mock.mock(fn
        %{method: :post, url: "http://app:4001/api/order/"} ->
          %Tesla.Env{
            status: 201,
            body: %{
              "id" => Ecto.UUID.generate(),
              "total_order" => "11.0",
              "link_for_payment" => "qr_code_link"
            }
          }
      end)

      # Monta novo conn com header de autorização
      auth_conn_not_admin =
        build_conn()
        |> put_req_header("authorization", "Bearer #{json_not_admin["token"]}")

      conn_order = post(auth_conn_not_admin, "/api/order/", order)
      json_order = json_response(conn_order, 201)
      assert json_order["link_for_payment"] == "qr_code_link"
      assert json_order["total_order"] == "11.0"
      assert json_order["status"] == "created"

      id_order = json_order["id"]
      url = "http://app:4001/api/order/#{id_order}"

      # usuario verifica o pedido
      Tesla.Mock.mock(fn
        %{method: :get, url: ^url} ->
          %Tesla.Env{
            status: 200,
            body: %{
              "products" => [
                %{"product_name" => "milkshake morango doce azedo"}
              ],
              "total" => "11.0",
              "payment_status" => false
            }
          }
      end)

      conn_order = get(auth_conn_not_admin, "/api/open/order/#{id_order}")
      json = json_response(conn_order, 200)
      assert json["payment_status"] == false
      assert json["status"] == "show"

      assert is_list(json["products"])
      assert length(json["products"]) == 1

      product = hd(json["products"])
      assert product["product_name"] == "milkshake morango doce azedo"

      page = "1"
      page_size = "5"
      url = "http://app:4001/api/order/orders/?page=#{page}&page_size=#{page_size}"

      # usuario admin verifica o pedido
      Tesla.Mock.mock(fn
        %{method: :get, url: ^url} ->
          %Tesla.Env{
            status: 200,
            body: [
              %{
                "id" => id_order,
                "products" => [
                  %{"product_name" => "milkshake morango doce azedo"}
                ],
                "total" => "11.0",
                "payment_status" => false,
                "order_status" => "recebido"
              }
            ]
          }
      end)

      conn_order = get(auth_conn_admin, "/api/order/orders?page=#{page}&page_size=#{page_size}")
      json = json_response(conn_order, 200)

      assert length(json) == 1

      # admin atualiza o pedido para em preparacao pos receber o pagamento
      params = %{"order_status" => "em_preparacao"}
      url = "http://app:4001/api/order/#{id_order}"

      Tesla.Mock.mock(fn
        %{method: :put, url: ^url} ->
          %Tesla.Env{
            status: 200,
            body: %{
              "total" => "11.0",
              "payment_status" => true,
              "order_status" => "recebido",
              "is_finished?" => false
            }
          }
      end)

      conn_order = put(auth_conn_admin, "/api/order/#{id_order}", params)
      json = json_response(conn_order, 200)

      assert json["is_finished?"] == false
      assert json["order_status"] == "recebido"
    end
  end
end
