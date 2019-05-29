defmodule BookclubWeb.ExternalVerificationControllerTest do
  use BookclubWeb.ConnCase

  test "Android Verification", %{conn: conn} do
    conn = get(conn, "/.well-known/assetlinks.json")
    assert json_response(conn, 200)
  end

  test "iOS Verification", %{conn: conn} do
    conn = get(conn, "/.well-known/apple-app-site-association")
    assert json_response(conn, 200)
  end
end
