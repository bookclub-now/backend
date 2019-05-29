defmodule BookclubWeb.ClubController do
  use BookclubWeb, :controller
  alias Bookclub.Clubs
  alias Bookclub.Clubs.Book

  action_fallback(BookclubWeb.FallBackController)

  def index(%Plug.Conn{assigns: %{session_user: session_user}} = conn, _params) do
    {:ok, clubs} = Clubs.list_user_clubs(user_id: session_user.id)
    render(conn, "clubs.json", clubs: clubs)
  end

  def create(%Plug.Conn{assigns: %{session_user: session_user}} = conn, params) do
    with {:ok, %Book{} = book} <- Clubs.create_book(params),
         {:ok, club} <- Clubs.create_club(%{user_id: session_user.id, book_id: book.id}),
         {:ok, _member} <- Clubs.ClubMembers.join_club!(session_user, club) do
      render(conn, "created_book.json", book: book, club: club)
    else
      {:error,
       %Ecto.Changeset{
         changes: %{google_book_id: google_book_id},
         errors: [google_book_id: {"has already been taken", _}]
       }} ->
        {:ok, %Book{} = book} = Clubs.find_book(google_book_id: google_book_id)
        {:ok, club} = Clubs.create_club(%{user_id: session_user.id, book_id: book.id})
        {:ok, _member} = Clubs.ClubMembers.join_club!(session_user, club)
        render(conn, "created_book.json", book: book, club: club)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
