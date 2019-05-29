defmodule BookclubWeb.PageControllerTest do
  use BookclubWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Bookclub"
  end
end
