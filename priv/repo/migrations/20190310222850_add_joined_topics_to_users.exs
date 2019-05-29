defmodule Bookclub.Repo.Migrations.AddJoinedTopicsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :joined_topics, {:array, :string}
    end
  end
end
