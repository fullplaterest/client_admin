defmodule ClientAdmin.MongoRepo do
  def insert_one(collection, doc) do
    Mongo.insert_one(:mongo, collection, doc)
  end

  def find_one(collection, filter) do
    Mongo.find_one(:mongo, collection, filter)
  end

  def find_all(collection), do:
    Mongo.find(:mongo, collection, %{}) |> Enum.to_list()
end
