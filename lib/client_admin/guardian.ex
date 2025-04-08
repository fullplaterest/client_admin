defmodule ClientAdmin.Guardian do
  use Guardian, otp_app: :client_admin

  def subject_for_token(user, _claims) do
    {:ok, BSON.ObjectId.encode!(user["_id"])}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = ClientAdmin.MongoRepo.find_one("users", %{"_id" => BSON.ObjectId.decode!(id)})

    case user do
      nil -> {:error, :not_found}
      _ -> {:ok, user}
    end
  end
end
