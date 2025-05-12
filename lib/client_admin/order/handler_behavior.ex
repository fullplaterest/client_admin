defmodule ClientAdmin.Order.HandlerBehavior do
  @callback create(map(), map() | nil) :: {:ok, any()} | {:error, any()}
  @callback create(map(), map()) :: {:ok, map()} | {:error, any()}
  @callback get_one(map()) :: {:ok, map()} | {:error, any()}
  @callback list(map()) :: {:ok, list()} | {:error, any()}
  @callback update(map()) :: {:ok, map()} | {:error, any()}
end
