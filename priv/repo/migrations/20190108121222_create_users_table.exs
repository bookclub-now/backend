defmodule Bookclub.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:first_name, :string)
      add(:last_name, :string)
      add(:email, :string)
      add(:password_hash, :string)
      add(:type, :integer)
      add(:photo_url, :string)
      add(:phone_number, :string)
      add(:date_of_birth, :date)

      timestamps()
    end

    create(unique_index(:users, :email))
    create(unique_index(:users, :phone_number))
  end
end
