defmodule ClientAdminWeb.Jsons.ProductJson do
  def product(%{product: product, status: status}) do
    %{
      id: product["id"],
      product_name: product["product_name"],
      description: product["description"],
      price: product["price"],
      status: status
    }
  end

  def product_list(%{product: products}) do
    Enum.map(products, fn product ->
      %{
        id: product["id"],
        product_name: product["product_name"],
        description: product["description"],
        price: product["price"]
      }
    end)
  end
end
