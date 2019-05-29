defmodule BookclubWeb.Admin.ClubControllerTest do
  use BookclubWeb.ConnCase, async: true

  alias Bookclub.Accounts.User
  alias Bookclub.Test.Suport.Fixtures

  @moduletag :admin

  setup %{conn: conn} do
    user = Fixtures.user_fixture(%{type: User.types().admin.id})
    [conn: Fixtures.auth(conn, user)]
  end

  describe "index" do
    test "lists all clubs", %{conn: conn} do
      conn = get(conn, Routes.admin_club_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Clubs"
    end
  end
end
