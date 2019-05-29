defmodule Bookclub.Auth.UserType do
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  alias Bookclub.Auth.Guardian, as: Auth
  alias Bookclub.Helpers
  alias Bookclub.Accounts.User

  def init(default), do: {User.types(), default}

  def call(conn, {available_types, :admin}) do
    verify(conn, [available_types.admin.id], &redirect_to_login/1)
  end

  def call(conn, {available_types, :regular}) do
    verify(conn, [available_types.admin.id, available_types.regular.id], &stop_connection/1)
  end

  def call(conn, _opts) do
    stop_connection(conn)
  end

  defp verify(conn, allowed_types, fallback_action) do
    with %User{type: type} = user <- Auth.Plug.current_resource(conn),
         true <- Enum.member?(allowed_types, type) do
      assign(conn, :session_user, user)
    else
      _ -> fallback_action.(conn)
    end
  end

  defp stop_connection(conn) do
    conn
    |> Helpers.send_error(401, "unauthorized")
    |> halt()
  end

  defp redirect_to_login(conn) do
    conn
    |> redirect(to: "/login/signin")
    |> halt()
  end
end
