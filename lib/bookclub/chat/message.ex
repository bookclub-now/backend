defmodule Bookclub.Chat.Message do
  @moduledoc """
  Describes how a persisted message looks like.
  Offers a set of functions for reading and writing messages.

  It's the output perspective of
  `BookclubWeb.Channels.ChatRoomChannel`.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Bookclub.{
    Accounts.User,
    Repo,
    TypeHelpers
  }

  @max_text_size 2048

  schema "messages" do
    belongs_to(:user, Bookclub.Accounts.User)
    belongs_to(:club, Bookclub.Clubs.Club)

    field(:chapter, :integer)
    field(:user_display_name, :string)
    field(:text, :string)
    field(:checksum, :string)

    timestamps()
  end

  @message_params [
    :user_id,
    :club_id,
    :chapter,
    :user_display_name,
    :text,
    :checksum
  ]

  def changeset(message, params \\ %{}) do
    message
    |> cast(params, @message_params)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:club_id)
    |> validate_required(@message_params)
  end

  def commit(user, topic, raw_payload) do
    with {:not_user, %User{}} <- {:not_user, user},
         {:ok, {club_id, chapter}} <- topic_id(topic),
         {:ok, payload} <- sanitize_payload(raw_payload),
         msg_build <- build_message(user, club_id, chapter, payload) do
      %__MODULE__{}
      |> changeset(msg_build)
      |> Repo.insert()
    else
      error -> error
    end
  end

  def load_from(topic, payload) do
    with {:ok, {club, chapter}} <- topic_id(topic),
         %{"last_message_timestamp" => raw_timestamp} <- payload,
         {:ok, last_msg_timestamp} <- NaiveDateTime.from_iso8601(raw_timestamp) do
      Repo.all(load_messages_query(club, chapter, last_msg_timestamp))
    else
      error -> error
    end
  end

  # def get_messages(topic, limit \\ 100) do
  #   with {:ok, {club, chapter}} <- topic_id(topic) do
  #     club
  #     |> get_messages_query(chapter, limit)
  #     |> Repo.all()
  #   else
  #     error -> error
  #   end
  # end

  def topic_id("chat_room:" <> topic_id) do
    with [raw_club_id, raw_chapter] <- String.split(topic_id, "/"),
         true <- TypeHelpers.is_binary_integer(raw_club_id),
         true <- TypeHelpers.is_binary_integer(raw_chapter),
         club_id <- TypeHelpers.parse_integer(raw_club_id),
         chapter <- TypeHelpers.parse_integer(raw_chapter) do
      {:ok, {club_id, chapter}}
    else
      _e -> {:error, :invalid_topic}
    end
  end

  def topic_to_text({club_id, chapter}), do: "#{club_id}/#{chapter}"

  defp build_message(user, club_id, chapter, payload) do
    %{
      user_id: user.id,
      club_id: club_id,
      chapter: chapter,
      user_display_name: "#{user.first_name} #{user.last_name}",
      text: payload.text,
      checksum: checksum(payload.text)
    }
  end

  defp sanitize_payload(payload) do
    with %{"text" => text} <- payload,
         true <- String.length(text) <= @max_text_size do
      {:ok, %{text: text}}
    else
      _error -> {:error, :invalid_payload}
    end
  end

  defp load_messages_query(club_id, chapter, last_msg_timestamp) do
    from(message in __MODULE__,
      where: message.club_id == ^club_id,
      where: message.chapter == ^chapter,
      where: message.inserted_at >= ^last_msg_timestamp,
      limit: 100,
      order_by: [asc: message.inserted_at]
    )
  end

  defp checksum(text) do
    :sha
    |> :crypto.hash(text)
    |> Base.encode16(case: :lower)
  end
end
