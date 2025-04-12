defmodule ClientAdmin.User.HandlerTest do
  use ExUnit.Case
  alias ClientAdmin.User.Handler

  describe "user_clean/2" do
    test "limpa as informacoes do usuario e coloca em um mapa" do
      user = %{
        "_id" => BSON.ObjectId.decode!("67faf2d5e5159b0001de5b5b"),
        "admin" => true,
        "cpf" => "01589509335",
        "email" => "teste@example.com",
        "password_hash" =>
          "$argon2id$v=19$m=65536,t=8,p=2$MWU9qyyl5VYlVy3INW1IUA$xR2ULsXkDSk0ipTXrPbNZt0KUbyz2kgCoJ+5Cwt2CJg",
        "token" =>
          "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJjbGllbnRfYWRtaW4iLCJleHAiOjE3NDY5MTg2MTMsImlhdCI6MTc0NDQ5OTQxMywiaXNzIjoiY2xpZW50X2FkbWluIiwianRpIjoiYWUwNmYxMGYtZjY1ZS00YzE4LTlmYjgtMzE3MzE5ZjU4Y2Y3IiwibmJmIjoxNzQ0NDk5NDEyLCJzdWIiOiI2N2ZhZjJkNWU1MTU5YjAwMDFkZTViNWIiLCJ0eXAiOiJhY2Nlc3MifQ.W_OFuhTvN7Imkd0vhYVfAXCG4ZJjub3Wa3vMmD6BeA1PpGjheK5x5NBiW1GNE5P4Pu0k1k0W0xrFMpfR9N4zlw"
      }

      {:ok, user_cleaned} = Handler.user_clean(user)

    assert user_cleaned == %{
       "id" => "67faf2d5e5159b0001de5b5b",
       "cpf" => user["cpf"],
       "email" => user["email"]
     }
    end
  end
end
