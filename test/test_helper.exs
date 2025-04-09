ExUnit.start()
Mimic.copy(Mongo)
Mimic.copy(ClientAdmin.MongoRepo)
Mimic.copy(ClientAdmin.Guardian)

defmodule MongoTestHelper do
  def drop_all_collections do
    Mongo.show_collections(:mongo)
    |> Enum.each(fn col ->
      Mongo.delete_many(:mongo, col, %{})
    end)
  end
end
