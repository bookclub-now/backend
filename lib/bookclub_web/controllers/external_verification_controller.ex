defmodule BookclubWeb.ExternalVerificationController do
  use BookclubWeb, :controller

  action_fallback(BookclubWeb.FallBackController)

  def android_association(conn, _params) do
    render(conn, "android_association.json")
  end

  def ios_association(conn, _params) do
    render(conn, "ios_association.json")
  end
end
