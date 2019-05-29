defmodule BookclubWeb.AccountView do
  use BookclubWeb, :view

  def render("token.json", %{token: token}) do
    %{token: token}
  end

  def render("user.json", %{user: user}) do
    %{
      user: %{
        first_name: user.first_name,
        last_name: user.last_name
      }
    }
  end

  def render("raw_user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name
    }
  end

  def render("my_account.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      photo_url: user.photo_url,
      phone_number: user.phone_number,
      date_of_birth: user.date_of_birth,
      expo_push_tokens: user.expo_push_tokens,
      joined_topics: user.joined_topics,
      metadata: user.metadata,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  def render("profile.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      photo_url: user.photo_url
    }
  end
end
