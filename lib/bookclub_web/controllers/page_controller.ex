defmodule BookclubWeb.PageController do
  use BookclubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def reset_password(conn, _params) do
    render(conn, "reset_password.html")
  end
end
