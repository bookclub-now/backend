defmodule Bookclub.ClubsTest do
  use Bookclub.DataCase, async: true

  alias Bookclub.Clubs
  alias Bookclub.Clubs.{Book, Club}
  alias Bookclub.Test.Suport.Fixtures

  @moduletag :clubs

  describe "clubs" do
    @invalid_attrs %{user_id: nil, book_id: nil}

    test "list_clubs/0 returns all clubs" do
      Fixtures.club_fixture()
      assert Enum.count(Clubs.list_clubs()) == 1
    end

    test "create_club/1 with valid data creates a club" do
      assert {:ok, %Club{} = club} = Clubs.create_club(Fixtures.club_data())
    end

    test "create_club/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clubs.create_club(@invalid_attrs)
    end
  end

  describe "books" do
    @invalid_attrs %{name: nil, author: nil}

    test "create_book/1 with valid data creates a book" do
      assert {:ok, %Book{} = book} = Clubs.create_book(Fixtures.book_data())
      assert book.name == "Example"
      assert book.author == "Example"
      assert book.chapters == 10
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clubs.create_book(@invalid_attrs)
    end
  end
end
