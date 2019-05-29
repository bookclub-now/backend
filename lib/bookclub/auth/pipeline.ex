defmodule Bookclub.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bookclub,
    error_handler: Bookclub.Auth.ErrorHandler,
    module: Bookclub.Auth.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  plug Guardian.Plug.LoadResource, allow_blank: true
end
