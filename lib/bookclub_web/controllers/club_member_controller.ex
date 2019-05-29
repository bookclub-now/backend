defmodule BookclubWeb.ClubMemberController do
  use BookclubWeb, :controller
  alias Bookclub.Clubs
  alias Bookclub.Clubs.ClubMembers

  action_fallback(BookclubWeb.FallBackController)

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(%Plug.Conn{assigns: %{session_user: user}} = conn, params) do
    with {:ok, club} <- Clubs.find_club(id: params["club_id"]),
         {:ok, _member} <- ClubMembers.join_club(user, club, params["join_code"]) do
      send_resp(conn, 204, "")
    else
      _error -> send_resp(conn, 403, "")
    end
  end

  def destroy(%Plug.Conn{assigns: %{session_user: user}} = conn, params) do
    with {:ok, club} <- Clubs.find_club(id: params["club_id"]),
         {:ok, :left} <- ClubMembers.leave_club(user, club) do
      send_resp(conn, 204, "")
    else
      _error -> send_resp(conn, 404, "")
    end
  end
end
