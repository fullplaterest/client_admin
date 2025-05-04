defmodule ClientAdmin.Product.HandlerBehaviour do
  @callback create(map(), map() | nil) :: {:ok, any()} | {:error, any()}
end
