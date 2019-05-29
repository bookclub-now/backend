defmodule Bookclub.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Bookclub.Chat.Message
  alias Bookclub.Repo
  alias Bookclub.Accounts.{User, Login}

  def join_chat_topic(user, club_id, chapter) do
    with topic_text <- Message.topic_to_text({club_id, chapter}) do
      case user.joined_topics do
        nil ->
          update_user(:internal, user, topic_attr([topic_text]))

        topics ->
          check_joined_to_join(user, topic_text, topics)
      end
    end
  end

  defp check_joined_to_join(user, topic_text, topics) do
    case Enum.member?(topics, topic_text) do
      true ->
        {:ok, user}

      _any ->
        update_user(:internal, user, topic_attr([topic_text | topics]))
    end
  end

  defp topic_attr(topics) do
    %{"joined_topics" => topics}
  end

  def add_expo_push_token(user, token) do
    case user.expo_push_tokens do
      nil ->
        update_user(:internal, user, expo_attr([token]))

      tokens ->
        check_to_update(user, tokens, token)
    end
  end

  defp check_to_update(user, tokens, token) do
    case Enum.member?(tokens, token) do
      false ->
        update_user(:internal, user, expo_attr([token | tokens]))

      _any ->
        {:ok, user}
    end
  end

  def remove_expo_push_token(user, token) do
    case user.expo_push_tokens do
      nil ->
        {:ok, user}

      tokens ->
        update_user(:internal, user, expo_attr(List.delete(tokens, token)))
    end
  end

  def gen_reset_token(user) do
    update_user(:internal, user, %{"reset_token" => do_gen_reset_token(), "reset_token_birth" => NaiveDateTime.utc_now()})
  end

  def clear_reset_token(user) do
    update_user(:internal, user, %{"reset_token" => nil, "reset_token_birth" => nil})
  end

  def reset_password(user, params) do
    update_user(:update_by_api, user, %{"password" => params["password"]})
  end

  defp expo_attr(tokens) do
    %{"expo_push_tokens" => tokens}
  end

  def write_metadata(user, metadata) do
    update_user(:internal, user, %{"metadata" => metadata})
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  def find_by_email(email), do: Repo.get_by(User, email: email)

  def create_user(:admin_changeset, attrs) do
    create_account(:create_by_admin, attrs)
  end

  def create_user(:api_changeset, attrs) do
    create_account(:create_by_api, attrs)
  end

  def update_user(:admin_changeset, %User{} = user, attrs) do
    update_account(:update_by_admin, user, attrs)
  end

  def update_user(:api_changeset, %User{} = user, attrs) do
    update_account(:update_by_api, user, attrs)
  end

  def update_user(:internal, %User{} = user, attrs) do
    update_account(:internal, user, attrs)
  end

  def update_user(:update_by_api, %User{} = user, attrs) do
    update_account(:update_by_api, user, attrs)
  end

  defp create_account(changeset_type, attrs) do
    changeset_type
    |> User.changeset(%User{}, attrs)
    |> Repo.insert()
  end

  defp update_account(changeset_type, user, attrs) do
    changeset_type
    |> User.changeset(user, attrs)
    |> Repo.update()
  end

  defp do_gen_reset_token do
    with length <- Enum.random(32..39),
         bytes <- :crypto.strong_rand_bytes(length),
         hash <- :crypto.hash(:sha, bytes),
         base <- Base.encode16(hash, case: :lower),
         code <- binary_part(base, 0, length) do
      code
    end
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking login changes.

  ## Examples

      iex> change_login(login)
      %Ecto.Changeset{source: %Login{}}

  """
  def change_login(%Login{} = login) do
    Login.changeset(login, %{})
  end

  @doc """
  Authenticates only admin

  ## Examples

    iex> signin(:admin, attrs)
    {:ok, %User{}}

    iex> signin(:admin, attrs)
    {:error, %Ecto.Changeset{}}

  """
  def signin(:admin, attrs) do
    authenticate(attrs, type: User.types().admin.id)
  end

  @doc """
  Authenticates admin / regular

  ## Examples

    iex> signin(:regular, attrs)
    {:ok, %User{}}

    iex> signin(:regular, attrs)
    {:error, %Ecto.Changeset{}}

  """
  def signin(:regular, attrs) do
    authenticate(attrs)
  end

  defp authenticate(attrs, conditions \\ []) do
    changeset = %Ecto.Changeset{Login.changeset(%Login{}, attrs) | action: :signin}

    if changeset.valid? do
      changes = changeset.changes
      conditions = [email: changes.email] ++ conditions

      with %User{} = user <- Repo.get_by(User, conditions),
           {:ok, user} <- Comeonin.Bcrypt.check_pass(user, changes.password) do
        {:ok, user}
      else
        _ ->
          changeset =
            changeset
            |> Ecto.Changeset.add_error(:password, "Invalid Authentication")

          {:error, changeset}
      end
    else
      {:error, changeset}
    end
  end
end
