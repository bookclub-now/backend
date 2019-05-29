defmodule Bookclub.Test.Suport.Fixtures do
  import Plug.Conn, only: [put_req_header: 3]
  alias Bookclub.{Accounts, Clubs}
  alias Bookclub.Auth.Guardian, as: Auth

  def user_data do
    %{
      first_name: "Example",
      last_name: "Example",
      email: "#{:rand.uniform()}@foxbox.com",
      password: "123",
      phone_number: "#{:rand.uniform()}",
      type: 1
    }
  end

  def user_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(user_data())

    {:ok, user} = Accounts.create_user(:admin_changeset, attrs)

    user
  end

  def club_data do
    user = user_fixture()
    book = book_fixture()

    %{
      user_id: user.id,
      book_id: book.id
    }
  end

  def club_fixture(attrs \\ %{}) do
    {:ok, club} =
      attrs
      |> Enum.into(club_data())
      |> Clubs.create_club()

    user = Accounts.get_user!(club.user_id)
    Clubs.ClubMembers.join_club!(user, club)

    club
  end

  def club_member_data do
    user = user_fixture()
    club = club_fixture()

    %{
      user_id: user.id,
      club_id: club.id
    }
  end

  def club_member_fixture(attrs \\ %{}) do
    {:ok, club_member} =
      attrs
      |> Enum.into(club_member_data())
      |> Clubs.ClubMembers.create_club_member()

    club_member
  end

  def book_data do
    %{
      "name" => "Example",
      "author" => "Example",
      "chapters" => 10,
      "google_book_id" => "#{:rand.uniform()}",
      "photo_url" => "https://dummyimage.com/600x400/000/fff&text=Book"
    }
  end

  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(book_data())
      |> Clubs.create_book()

    book
  end

  def message_data do
    user = user_fixture()
    club = club_fixture()
    {:ok, display_name} = Accounts.User.get_display_name(user.id)

    %Bookclub.Chat.Message{
      user_id: user.id,
      club_id: club.id,
      chapter: 1,
      user_display_name: display_name,
      text: "Hello, Mike.",
      checksum: "4d1bf1a6109aead91799b9e08c3aeaf55bc0ce00"
    }
  end

  def message_fixture do
    {:ok, message} = Bookclub.Repo.insert(message_data())

    message
  end

  def auth(conn, user) do
    {:ok, token, _} = Auth.encode_and_sign(user, %{}, token_type: :access)

    conn
    |> put_req_header("authorization", "bearer: " <> token)
  end
end
