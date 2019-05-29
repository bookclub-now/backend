defmodule BookclubWeb.ChatInfoView do
  use BookclubWeb, :view

  def render("chat_info.json", %{info: info}) do
    info
  end
end
