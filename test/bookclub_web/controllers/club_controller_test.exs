defmodule BookclubWeb.ClubControllerTest do
  use BookclubWeb.ConnCase, async: true
  alias Bookclub.Test.Suport.Fixtures

  @moduletag :clubs_api

  setup %{conn: conn} do
    user = Fixtures.user_fixture()
    [conn: Fixtures.auth(conn, user), user: user]
  end

  describe "POST /api/clubs" do
    test "creates bookclub", %{conn: conn} do
      params = %{
        "name" => "Example",
        "author" => "Example",
        "chapters" => 10,
        "google_book_id" => "1",
        "photo_url" => "https://dummyimage.com/600x400/000/fff&text=Book"
      }

      conn = post(conn, Routes.api_club_path(conn, :create, params))

      assert json_response(conn, 200)["book"]
    end

    test "avoids duplicate bookclubs", %{conn: conn} do
      params = %{
        "name" => "Example",
        "author" => "Example",
        "chapters" => 10,
        "google_book_id" => "1",
        "photo_url" => "https://dummyimage.com/600x400/000/fff&text=Book"
      }

      post(conn, Routes.api_club_path(conn, :create, params))
      conn = post(conn, Routes.api_club_path(conn, :create, %{params | "name" => "Duplicate"}))

      assert json_response(conn, 200)["book"]
    end

    test "invalid params", %{conn: conn} do
      params = %{
        "name" => "Example",
        "author" => "Example",
        "photo_url" => "https://dummyimage.com/600x400/000/fff&text=Book"
      }

      conn = post(conn, Routes.api_club_path(conn, :create, params))

      response = json_response(conn, 422)["errors"]

      assert response == %{"chapters" => ["can't be blank"]}
    end
  end

  describe "GET /api/clubs" do
    test "returns owners' and members' clubs", %{conn: conn, user: user} do
      club_member = Fixtures.club_member_fixture(%{user_id: user.id})
      Fixtures.club_fixture(%{user_id: user.id})
      Fixtures.club_fixture(%{user_id: user.id})
      Fixtures.club_member_fixture(%{club_id: club_member.club_id})
      Fixtures.club_member_fixture(%{club_id: club_member.club_id})

      conn = get(conn, Routes.api_club_path(conn, :index))

      response = json_response(conn, 200)
      first_response = Enum.at(response, 0)

      assert Enum.count(response) == 3
      assert Enum.count(first_response["members"]) == 4
    end

    test "returns members' clubs", %{conn: conn, user: user} do
      club_a = Fixtures.club_fixture()
      club_b = Fixtures.club_fixture()

      Fixtures.club_member_fixture(%{club_id: club_a.id, user_id: user.id})
      Fixtures.club_member_fixture(%{club_id: club_b.id, user_id: user.id})

      Fixtures.club_member_fixture(%{club_id: club_a.id})
      Fixtures.club_member_fixture(%{club_id: club_a.id})

      conn = get(conn, Routes.api_club_path(conn, :index))

      response = json_response(conn, 200)
      first_response = Enum.at(response, 0)

      assert Enum.count(response) == 2
      assert Enum.count(first_response["members"]) == 4
    end
  end
end
