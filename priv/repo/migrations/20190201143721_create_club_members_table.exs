defmodule Bookclub.Repo.Migrations.CreateClubMembersTable do
  use Ecto.Migration

  def change do
    create table(:club_members) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:club_id, references(:clubs, on_delete: :delete_all))

      timestamps()
    end

    create(index(:club_members, [:user_id]))
    create(index(:club_members, [:club_id]))
    create(unique_index(:club_members, [:user_id, :club_id]))
  end
end
