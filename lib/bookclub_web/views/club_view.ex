defmodule BookclubWeb.ClubView do
  use BookclubWeb, :view

  def render("clubs.json", %{clubs: clubs}) do
    render_many(clubs, BookclubWeb.ClubView, "club.json", as: :club)
  end

  def render("club.json", %{club: club}) do
    %{
      id: club.id,
      owner_id: club.user_id,
      join_code: club.join_code,
      members: render_many(club.members, BookclubWeb.AccountView, "raw_user.json", as: :user),
      book: render_one(club.book, BookclubWeb.ClubView, "book.json", as: :book)[:book],
      inserted_at: club.inserted_at
    }
  end

  def render("book.json", %{book: book}) do
    %{
      book: %{
        book_id: book.id,
        name: book.name,
        author: book.author,
        photo_url: book.photo_url,
        chapters: book.chapters,
        google_book_id: book.google_book_id
      }
    }
  end

  def render("created_book.json", %{book: book, club: club}) do
    %{
      book: %{
        club_id: club.id,
        club_join_code: club.join_code,
        book_id: book.id,
        name: book.name,
        author: book.author,
        photo_url: book.photo_url,
        chapters: book.chapters,
        google_book_id: book.google_book_id
      }
    }
  end
end
