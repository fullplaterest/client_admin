defmodule ClientAdmin.User.Handler do
  def user_clean(user) do
    {:ok,
     %{
       "id" => BSON.ObjectId.encode!(user["_id"]),
       "cpf" => user["cpf"],
       "email" => user["email"]
     }}
  end
end
