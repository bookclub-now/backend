defmodule Bookclub.Repo.Migrations.AddJoinCodeToClubs do
  use Ecto.Migration

  def change do
    alter table(:clubs) do
      add :join_code, :string
    end
  end
end
