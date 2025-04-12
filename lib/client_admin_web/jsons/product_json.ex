defmodule ClientAdminWeb.Jsons.ProductJson do
  def product(%{product: product, status: status}) do
    %{id: product.id, status: status, product: product.product_name}
  end

  def product_list(%{product: products}) do
    Enum.map(products, fn product ->
      %{
        id: product.id,
        product_name: product.product_name,
        description: product.description,
        price: Decimal.to_string(product.price)
      }
    end)
  end
end
