defmodule ClientAdminWeb.Jsons.OrderJson do
  def order(%{order: order, status: status}) do
    %{
      id: order["id"],
      status: status,
      total_order: order["total_order"],
      link_for_payment: order["link_for_payment"]
    }
  end

  def order_get(%{order: order, status: status}) do
    %{
      status: status,
      products:
        Enum.map(order["products"], fn product ->
          product
        end),
      payment_status: order["payment_status"]
    }
  end

  def order_list_admin(%{order: orders}) do
    Enum.map(orders, fn order ->
      %{
        id: order["id"],
        products: order["products"],
        total: order["total"],
        payment_status: order["payment_status"],
        order_status: order["order_status"]
      }
    end)
  end

  def updated_order_admin(%{order: order}) do
    %{
      total: order["total"],
      payment_status: order["payment_status"],
      order_status: order["order_status"],
      is_finished?: order["is_finished?"]
    }
  end
end
