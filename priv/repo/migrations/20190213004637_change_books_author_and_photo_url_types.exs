defmodule Bookclub.Repo.Migrations.ChangeBooksAuthorAndPhotoUrlTypes do
  use Ecto.Migration

  def change do
    alter table(:books) do
      modify :author, :text
      modify :photo_url, :text
    end
  end
end
