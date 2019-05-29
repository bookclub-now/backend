defmodule Bookclub.Clubs.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field(:name, :string)
    field(:author, :string)
    field(:photo_url, :string)
    field(:google_book_id, :string)
    field(:chapters, :integer)

    timestamps()
  end

  @required_fields [:name, :author, :chapters]
  @optional_fields [:photo_url, :google_book_id]

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:google_book_id)
  end
end
