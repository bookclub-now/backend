defmodule Bookclub.LocalMailer do
  @postmark_endpoint "https://api.postmarkapp.com/email"

  def deliver(:password_reset, user) do
    with params <- request_params(user),
         result <- post(params),
         true <- valid?(result) do
      {:ok, :sent}
    else
      _any -> {:error, :unable_to_send_email}
    end
  end

  defp post(params) do
    HTTPoison.post(@postmark_endpoint, Jason.encode!(params), request_headers())
  end

  defp request_params(user) do
    %{
      From: postmark_sender(),
      To: user.email,
      Subject: "Password Reset",
      HtmlBody: "Hello, #{user.first_name}.<br /><br />
      Someone requested a password reset for your Bookclub account.<br />
      If it was you, you can use the following URL to proceed reseting it:<br /><br />
      <a href=\"#{reset_url(user)}\">#{reset_url(user)}</a>
      <br /><br />
      If you haven't requested a password reset, please ignore this e-mail."
    }
  end

  defp valid?(result) do
    case result do
      {:ok, %{status_code: 200}} -> true
      _any -> false
    end
  end

  defp reset_url(user) do
    BookclubWeb.Router.Helpers.page_url(BookclubWeb.Endpoint, :reset_password, user.id, user.reset_token)
  end

  defp request_headers do
    [
      content_json_header(),
      accept_json_header(),
      postmark_header()
    ]
  end

  defp content_json_header do
    {"content-type", "application/json"}
  end

  defp accept_json_header do
    {"accept", "application/json"}
  end

  defp postmark_header do
    {"X-Postmark-Server-Token", postmark_token()}
  end

  defp postmark_token do
    Application.get_env(:bookclub, :postmark_server_token)
  end

  defp postmark_sender do
    Application.get_env(:bookclub, :postmark_sender)
  end
end
