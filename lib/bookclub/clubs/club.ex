defmodule Bookclub.Clubs.Club do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clubs" do
    belongs_to(:user, Bookclub.Accounts.User)
    belongs_to(:book, Bookclub.Clubs.Book)
    many_to_many(:members, Bookclub.Accounts.User, join_through: Bookclub.Clubs.ClubMember)
    field(:join_code)

    timestamps()
  end

  @required_fields [:user_id, :book_id]

  def changeset(schema, attrs) do
    schema
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
