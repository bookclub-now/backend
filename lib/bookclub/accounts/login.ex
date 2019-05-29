defmodule Bookclub.Accounts.Login do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:email, :string)
    field(:password, :string)
  end

  @required_fields ~w(email password)a

  def changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_format(:email, ~r/@/)
  end
end
