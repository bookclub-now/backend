defmodule BookclubWeb.Admin.UserView do
  use BookclubWeb, :view
  alias Bookclub.Accounts.User

  def load(:types), do: User.types() |> Enum.map(fn {_key, val} -> {val.label, val.id} end)

  def show_type(type_id) when is_integer(type_id) and type_id > 0 and type_id < 3 do
    {_, type} =
      User.types()
      |> Enum.find(fn {_key, val} -> val.id === type_id end)

    type.label
  end

  def show_type(_type_id) do
    "Undefined"
  end
end
