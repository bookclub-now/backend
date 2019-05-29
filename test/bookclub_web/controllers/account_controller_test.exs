defmodule BookclubWeb.AccountControllerTest do
  use BookclubWeb.ConnCase, async: true
  alias Bookclub.Test.Suport.Fixtures

  @moduletag :accounts_api

  describe "GET /api/accounts" do
    test "shows the current user when logged in", %{conn: conn} do
      user = Fixtures.user_fixture()
      conn = Fixtures.auth(conn, user)

      conn = get(conn, "/api/accounts")
      assert json_response(conn, 200)["email"] == user.email
    end

    test "will fail if the user is not logged in", %{conn: conn} do
      conn = get(conn, "/api/accounts")
      assert response(conn, 401)
    end
  end

  describe "GET /api/accounts/profile/:user_id" do
    test "shows a user when logged in", %{conn: conn} do
      user = Fixtures.user_fixture()
      friend = Fixtures.user_fixture()
      conn = Fixtures.auth(conn, user)

      conn = get(conn, "/api/accounts/profile/#{friend.id}")
      assert json_response(conn, 200)["id"] == friend.id
    end

    test "will fail when logged out", %{conn: conn} do
      user = Fixtures.user_fixture()

      conn = get(conn, "/api/accounts/profile/#{user.id}")
      assert response(conn, 401)
    end

    test "wont show user's sensitive information", %{conn: conn} do
      user = Fixtures.user_fixture()
      friend = Fixtures.user_fixture()
      conn = Fixtures.auth(conn, user)

      conn = get(conn, "/api/accounts/profile/#{friend.id}")
      assert json_response(conn, 200)["email"] == nil
      assert json_response(conn, 200)["phone_number"] == nil
      assert json_response(conn, 200)["date_of_birth"] == nil
    end

    test "fails for inexistent users", %{conn: conn} do
      user = Fixtures.user_fixture()
      conn = Fixtures.auth(conn, user)

      conn = get(conn, "/api/accounts/profile/999")
      assert response(conn, 404)
    end
  end

  describe "POST /api/accounts/signup" do
    test "returns errors when params are invalid", %{conn: conn} do
      params = %{
        "first_name" => "Example",
        "last_name" => "",
        "phone_number" => ""
      }

      conn =
        conn
        |> post(Routes.api_account_path(conn, :signup, params))

      assert json_response(conn, 422) == %{
               "errors" => %{
                 "last_name" => ["can't be blank"],
                 "phone_number" => ["can't be blank"],
                 "email" => ["can't be blank"],
                 "password" => ["can't be blank"]
               }
             }
    end

    test "avoids duplicate phone numbers", %{conn: conn} do
      Fixtures.user_fixture(%{phone_number: "+1-202-555-0178"})

      params = %{
        "first_name" => "Example",
        "last_name" => "Example",
        "phone_number" => "+1-202-555-0178",
        "email" => "any@foxbox.co",
        "password" => "any123"
      }

      conn =
        conn
        |> post(Routes.api_account_path(conn, :signup, params))

      assert json_response(conn, 422) == %{
               "errors" => %{"phone_number" => ["has already been taken"]}
             }
    end

    test "creates a valid account", %{conn: conn} do
      params = %{
        "first_name" => "Example",
        "last_name" => "Example",
        "phone_number" => "+5521968704588",
        "email" => "any@foxbox.co",
        "password" => "any123"
      }

      conn =
        conn
        |> post(Routes.api_account_path(conn, :signup, params))

      response = json_response(conn, 200)["user"]

      assert response["first_name"] == params["first_name"]
      assert response["last_name"] == params["last_name"]
    end
  end

  describe "POST /api/accounts/signin" do
    test "returns 401 when params are invalid", %{conn: conn} do
      conn =
        conn
        |> post(Routes.api_account_path(conn, :signin, %{}))

      assert json_response(conn, 401) == %{"errors" => "unauthorized"}
    end

    test "returns 401 when user does not exist", %{conn: conn} do
      params = %{
        "email" => "any@foxbox.co",
        "password" => "any123"
      }

      conn =
        conn
        |> post(Routes.api_account_path(conn, :signin, params))

      assert json_response(conn, 401) == %{"errors" => "unauthorized"}
    end

    test "returns token when using valid email and password", %{conn: conn} do
      params = %{
        "email" => "any@foxbox.co",
        "password" => "any123"
      }

      Fixtures.user_fixture(%{email: params["email"], password: params["password"]})

      conn =
        conn
        |> post(Routes.api_account_path(conn, :signin, params))

      response = json_response(conn, 200)

      assert Map.has_key?(response, "token")
    end
  end
end
