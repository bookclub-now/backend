defmodule Bookclub.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:club_id, references(:clubs, on_delete: :delete_all))
      add(:chapter, :integer)
      add(:user_display_name, :string)
      add(:text, :text)
      add(:checksum, :string)

      timestamps()
    end

    create(index(:messages, [:club_id, :chapter]))
    create(index(:messages, [:checksum]))
  end
end
