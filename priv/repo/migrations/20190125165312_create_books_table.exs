defmodule Bookclub.Repo.Migrations.CreateBooksTable do
  use Ecto.Migration

  def change do
    create table(:books) do
      add(:name, :string)
      add(:author, :string)
      add(:photo_url, :string)
      add(:google_book_id, :string)
      add(:chapters, :integer)

      timestamps()
    end

    create(unique_index(:books, :google_book_id))
  end
end
