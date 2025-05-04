ExUnit.start()
Mimic.copy(Mongo)
Mimic.copy(ClientAdmin.MongoRepo)
Mimic.copy(ClientAdmin.Guardian)
Application.put_env(:mox, :verify_on_exit, true)
Application.put_env(:client_admin, :product_handler, ClientAdmin.Product.HandlerMock)
Application.put_env(:client_admin, :order_handler, ClientAdmin.Order.HandlerMock)

defmodule MongoTestHelper do
  def drop_all_collections do
    Mongo.show_collections(:mongo)
    |> Enum.each(fn col ->
      Mongo.delete_many(:mongo, col, %{})
    end)
  end
end
