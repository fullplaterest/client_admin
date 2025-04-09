defmodule ClientAdmin.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:email, :string)
    field(:cpf, :string)
    field(:password, :string)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:email, :cpf, :password])
    |> validate_required([:email, :cpf, :password])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/)
    |> validate_length(:cpf, is: 11)
    |> validate_length(:password, min: 6)
  end
end
