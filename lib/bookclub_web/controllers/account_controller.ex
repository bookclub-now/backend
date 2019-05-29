defmodule BookclubWeb.AccountController do
  use BookclubWeb, :controller
  alias Bookclub.Auth.Guardian, as: Auth
  alias Bookclub.Accounts
  alias Bookclub.Accounts.User

  action_fallback(BookclubWeb.FallBackController)

  def signup(conn, params) do
    case Accounts.create_user(:api_changeset, params) do
      {:ok, %User{} = user} ->
        render(conn, "user.json", user: user)

      {:error, %Ecto.Changeset{} = changeset} ->
        send_error(conn, 422, changeset)
    end
  end

  def signin(conn, params) do
    case Accounts.signin(:regular, params) do
      {:ok, %User{} = user} ->
        render(conn, "token.json", token: build_token(user, "access"))

      _ ->
        send_error(conn, 401, "unauthorized")
    end
  end

  def signout(conn, _params) do
    conn
    |> Auth.Plug.sign_out()
    |> json(%{data: "OK"})
  end

  def my_account(%Plug.Conn{assigns: %{session_user: session_user}} = conn, _params) do
    render(conn, "my_account.json", user: session_user)
  end

  def show(conn, params) do
    with user when not is_nil(user) <- Accounts.get_user(params["user_id"]) do
      render(conn, "profile.json", user: user)
    else
      _error -> send_error(conn, 404, "not found")
    end
  end

  def add_expo_push_token(%Plug.Conn{assigns: %{session_user: user}} = conn, params) do
    with {:ok, _user} <- Accounts.add_expo_push_token(user, params["token"]) do
      send_resp(conn, 204, "")
    else
      _error -> send_resp(conn, 422, "")
    end
  end

  def remove_expo_push_token(%Plug.Conn{assigns: %{session_user: user}} = conn, params) do
    with {:ok, _user} <- Accounts.remove_expo_push_token(user, params["token"]) do
      send_resp(conn, 204, "")
    else
      _error -> send_resp(conn, 422, "")
    end
  end

  def write_metadata(%Plug.Conn{assigns: %{session_user: user}} = conn, params) do
    with {:ok, _user} <- Accounts.write_metadata(user, params["metadata"]) do
      send_resp(conn, 204, "")
    else
      _error -> send_resp(conn, 422, "")
    end
  end

  defp build_token(user, token_type) do
    {:ok, token, _} = Auth.encode_and_sign(user, %{}, token_type: token_type)
    token
  end
end
