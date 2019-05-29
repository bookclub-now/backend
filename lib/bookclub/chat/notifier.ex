defmodule Bookclub.Chat.Notifier do
  import Ecto.Query

  alias Bookclub.Chat.Message
  alias Bookclub.Chat.Presence
  alias Bookclub.Clubs.ClubMember
  alias Bookclub.Repo
  alias ExponentServerSdk.PushNotification, as: Expo

  def perform(socket, message) do
    with true <- Enum.member?([:prod, :dev], env()),
         online_ids <- online_users_ids(socket),
         topic_id when not is_nil(topic_id) <- socket.assigns.topic_id,
         msg_data <- prepare_message(topic_id, message),
         chunks <- notificable_token_chunks(topic_id, online_ids) do
      push_notifications(chunks, msg_data)
    end
  end

  defp push_notifications([], _msg_data), do: :ok

  defp push_notifications(chunks, msg_data) do
    chunks
    |> Enum.each(fn chunk -> push_chunk(chunk, msg_data) end)
  end

  defp push_chunk(chunk, msg_data) do
    chunk
    |> Enum.map(fn token ->
      %{
        to: token,
        title: msg_data.title,
        body: msg_data.body,
        data: msg_data.data
      }
    end)
    |> Expo.push_list()
  end

  defp online_users_ids(socket) do
    socket
    |> Presence.list()
    |> Map.keys()
  end

  defp notificable_token_chunks({club_id, _chapter} = topic_id, online_ids) do
    club_id
    |> get_members_query()
    |> Repo.all()
    |> Stream.map(fn m ->
      %{
        user_id: m.user_id,
        tokens: m.user.expo_push_tokens,
        joined_topics: m.user.joined_topics
      }
    end)
    |> Stream.filter(fn m ->
      not is_nil(m.tokens) &&
      not Enum.member?(online_ids, m.user_id) &&
      Enum.member?(m.joined_topics, Message.topic_to_text(topic_id))
    end)
    |> Stream.flat_map(fn m ->
      m.tokens
    end)
    |> Enum.chunk_every(100)
  end

  defp prepare_message(topic_id, message) do
    case String.length(message.text) do
      size when size > 25 ->
        %{
          title: message.user_display_name,
          data:  encode_topic(topic_id),
          body: String.slice(message.text, 0..25) <> "..."
        }

      _any ->
        %{
          title: message.user_display_name,
          data:  encode_topic(topic_id),
          body:  message.text
        }
    end
  end

  defp encode_topic({club_id, chapter}) do
    %{club_id: club_id, chapter: chapter}
  end

  defp get_members_query(club_id) do
    from m in ClubMember,
      where: m.club_id == ^club_id,
      join: user in assoc(m, :user),
      preload: [:user],
      select: [:club_id, :user_id, user: [:expo_push_tokens, :joined_topics]]
  end

  defp env do
    Application.get_env(:bookclub, :env)
  end
end
