defmodule BookclubWeb.ChatRoomControllerTest do
  use BookclubWeb.ConnCase

  test "GET /chat", %{conn: conn} do
    conn = get(conn, "/chat")
    assert html_response(conn, 200) =~ "Chat Room testing UI"
  end
end
