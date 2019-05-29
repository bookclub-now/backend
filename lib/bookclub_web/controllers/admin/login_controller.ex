defmodule BookclubWeb.Admin.LoginController do
  use BookclubWeb, :controller
  alias Bookclub.Accounts
  alias Bookclub.Accounts.{Login, User}
  alias Bookclub.Auth.Guardian, as: Auth

  def show(conn, _params) do
    changeset = Accounts.change_login(%Login{})
    render(conn, "show.html", changeset: changeset, action: build_action(conn))
  end

  def signin(conn, %{"login" => params}) do
    case Accounts.signin(:admin, params) do
      {:ok, %User{} = user} ->
        conn
        |> Auth.Plug.sign_in(user)
        |> redirect(to: Routes.admin_dash_board_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.html", changeset: changeset, action: build_action(conn))
    end
  end

  def signout(conn, _params) do
    conn
    |> Auth.Plug.sign_out()
    |> redirect(to: Routes.admin_login_path(conn, :show))
  end

  defp build_action(conn) do
    Routes.admin_login_path(conn, :signin)
  end
end
