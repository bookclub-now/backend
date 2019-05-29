defmodule Bookclub.Clubs.ClubMember do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "club_members" do
    belongs_to(:user, Bookclub.Accounts.User)
    belongs_to(:club, Bookclub.Clubs.Club)

    timestamps()
  end

  @required_fields [:user_id, :club_id]

  def changeset(schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:user_id,
      name: "club_members_user_id_club_id_index",
      message: "This user has already been taken for that club."
    )
  end
end
