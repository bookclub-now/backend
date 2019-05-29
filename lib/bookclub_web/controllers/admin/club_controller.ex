defmodule BookclubWeb.Admin.ClubController do
  use BookclubWeb, :controller

  alias Bookclub.Clubs

  def index(conn, _params) do
    clubs = Clubs.list_clubs()
    render(conn, "index.html", clubs: clubs)
  end
end
