defmodule Bookclub.Chat.Info do
  import Ecto.Query

  alias Bookclub.Chat.Message
  alias Bookclub.Repo

  def get(user, club) do
    user
    |> joined_chapters(club)
    |> do_get(club)
  end

  defp do_get(chapters, club) do
    chapters
    |> Enum.map(fn chapter ->
      %{
        chapter: chapter,
        count: count_messages(chapter, club)
      }
    end)
  end

  defp count_messages(chapter, club) do
    club.id
    |> message_count_query(chapter)
    |> Repo.one()
  end

  defp joined_chapters(user, club) do
    case user.joined_topics do
      nil ->
        []

      topics ->
        topics
        |> Stream.filter(fn topic ->
          is_from_club?(club, topic)
        end)
        |> Stream.map(fn topic ->
          to_chapter(topic)
        end)
    end
  end

  defp is_from_club?(club, topic) do
    with {:ok, {_club_id, chapter}} <- Message.topic_id("chat_room:#{topic}"),
         text <- Message.topic_to_text({"#{club.id}", chapter}),
         true <- (text == topic) do
      true
    else
      _any -> false
    end
  end

  defp to_chapter(topic) do
    with {:ok, {_club_id, chapter}} <- Message.topic_id("chat_room:#{topic}") do
      chapter
    end
  end

  defp message_count_query(club_id, chapter) do
    from m in Message,
      where: m.club_id == ^club_id,
      where: m.chapter == ^chapter,
      select: count("*")
  end
end
