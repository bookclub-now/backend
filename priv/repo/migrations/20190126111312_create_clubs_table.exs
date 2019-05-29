defmodule Bookclub.Repo.Migrations.CreateClubsTable do
  use Ecto.Migration

  def change do
    create table(:clubs) do
      add(:user_id, references(:users, on_delete: :nilify_all))
      add(:book_id, references(:books, on_delete: :nilify_all))

      timestamps()
    end

    create(index(:clubs, [:user_id]))
    create(index(:clubs, [:book_id]))
  end
end
