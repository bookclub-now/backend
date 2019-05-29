defmodule BookclubWeb.ChatInfoControllerTest do
  use BookclubWeb.ConnCase

  alias Bookclub.Test.Suport.Fixtures

  test "GET /:club_id/chat_info", %{conn: conn} do
    user = Fixtures.user_fixture()
    club = Fixtures.club_fixture()
    Bookclub.Clubs.ClubMembers.join_club!(user, club)
    conn = Fixtures.auth(conn, user)

    conn = get(conn, "/#{club.id}/chat_info")
    assert response(conn, 200)
  end
end
