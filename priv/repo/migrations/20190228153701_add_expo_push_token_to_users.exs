defmodule Bookclub.Repo.Migrations.AddExpoPushTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :expo_push_tokens, {:array, :string}
    end
  end
end
