defmodule BookclubWeb.ChatInfoController do
  use BookclubWeb, :controller

  alias Bookclub.Chat.Info
  alias Bookclub.Clubs

  action_fallback(BookclubWeb.FallBackController)

  def show(%Plug.Conn{assigns: %{session_user: user}} = conn, params) do
    with {:ok, club} <- Clubs.find_club(id: params["club_id"]),
         chat_info <- Info.get(user, club) do
      render(conn, "chat_info.json", info: chat_info)
    else
      _error -> send_resp(conn, 404, "")
    end
  end
end
