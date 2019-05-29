defmodule BookclubWeb.AccountPasswordResetController do
  use BookclubWeb, :controller

  alias Bookclub.Accounts

  action_fallback(BookclubWeb.FallBackController)

  def issue(conn, params) do
    with acc when not is_nil(acc) <- Accounts.find_by_email(params["email"]),
         {:ok, acc} <- Accounts.gen_reset_token(acc),
         {:ok, :sent} <- Bookclub.LocalMailer.deliver(:password_reset, acc) do
      send_resp(conn, 204, "")
    else
      _error -> send_resp(conn, 401, "")
    end
  end

  def check_token(conn, params) do
    with acc when not is_nil(acc) <- Accounts.get_user(params["id"]),
         true <- (acc.reset_token == params["reset_token"]) do
      send_resp(conn, 204, "")
    else
      _error -> send_resp(conn, 401, "")
    end
  end

  def reset(conn, params) do
    with acc when not is_nil(acc) <- Accounts.get_user(params["id"]),
         true <- (acc.reset_token == params["reset_token"]),
         true <- (3600 > NaiveDateTime.diff(NaiveDateTime.utc_now(), acc.reset_token_birth)),
         {:ok, acc} <- Accounts.clear_reset_token(acc),
         {:ok, _acc} <- Accounts.reset_password(acc, params) do
      send_resp(conn, 204, "")
    else
      _error -> send_resp(conn, 401, "")
    end
  end
end
