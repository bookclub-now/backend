defmodule Bookclub.Repo.Migrations.AddResetCodeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :reset_token, :string
      add :reset_token_birth, :naive_datetime
    end
  end
end
