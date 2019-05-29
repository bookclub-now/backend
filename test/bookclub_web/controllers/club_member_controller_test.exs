defmodule BookclubWeb.ClubMemberControllerTest do
  use BookclubWeb.ConnCase
  alias Bookclub.Test.Suport.Fixtures

  setup %{conn: conn} do
    user = Fixtures.user_fixture()
    club = Fixtures.club_fixture()

    {:ok, conn: Fixtures.auth(conn, user), user: user, club: club}
  end

  describe "Browser page" do
    test "GET /join/:club_id/:join_code", %{conn: conn} do
      conn = get(conn, "/join/1/foo")
      assert html_response(conn, 200) =~ "Link to download App"
    end
  end

  describe "Join a club" do
    test "Will join a club when everything is fine", %{conn: conn, club: club} do
      conn = post(conn, "/api/clubs/#{club.id}/join", %{join_code: club.join_code})
      assert response(conn, 204)
    end

    test "Won't join a club if the user owns it", %{conn: conn, club: club} do
      user = Bookclub.Accounts.get_user!(club.user_id)
      conn = Fixtures.auth(conn, user)
      conn = post(conn, "/api/clubs/#{club.id}/join", %{join_code: club.join_code})
      assert response(conn, 403)
    end

    test "Won't join a club twice", %{conn: conn, club: club} do
      conn = post(conn, "/api/clubs/#{club.id}/join", %{join_code: club.join_code})
      conn = post(conn, "/api/clubs/#{club.id}/join", %{join_code: club.join_code})

      assert response(conn, 403)
    end

    test "Fails for a inexistent club", %{conn: conn, club: club} do
      conn = post(conn, "/api/clubs/99/join", %{join_code: club.join_code})
      assert response(conn, 403)
    end

    test "Fails for a wrong join code", %{conn: conn, club: club} do
      conn = post(conn, "/api/clubs/#{club.id}/join", %{join_code: "Foo"})
      assert response(conn, 403)
    end
  end

  describe "Leave a club" do
    test "Will leave a club when everything is fine", %{conn: conn, club: club} do
      post(conn, "/api/clubs/#{club.id}/join", %{join_code: club.join_code})
      conn = delete(conn, "/api/clubs/#{club.id}/join")
      assert response(conn, 204)
    end

    test "Wont leave a club twice", %{conn: conn, club: club} do
      post(conn, "/api/clubs/#{club.id}/join", %{join_code: club.join_code})
      delete(conn, "/api/clubs/#{club.id}/join")
      conn = delete(conn, "/api/clubs/#{club.id}/join")
      assert response(conn, 404)
    end

    test "Wont leave a inexistent club", %{conn: conn} do
      conn = delete(conn, "/api/clubs/99/join")
      assert response(conn, 404)
    end

    test "Wont leave a club without being a member", %{conn: conn, club: club} do
      conn = delete(conn, "/api/clubs/#{club.id}/join")
      assert response(conn, 404)
    end
  end
end
