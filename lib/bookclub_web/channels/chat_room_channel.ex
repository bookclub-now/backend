defmodule BookclubWeb.ChatRoomChannel do
  @moduledoc """
  It's the main channel that handles all the chat input infra.
  Check out `Bookclub.Chat.Message` for the output perspective.
  """

  use BookclubWeb, :channel

  alias Bookclub.{
    Accounts,
    Chat.Message,
    Chat.Notifier,
    Chat.Presence,
    Clubs.ClubMembers
  }

  alias Guardian.Phoenix.Socket, as: GSocket

  def join(_topic, _payload, skt) do
    with topic <- skt.topic,
         {:ok, {club_id, chapter}} <- Message.topic_id(topic),
         user when not is_nil(user) <- GSocket.current_resource(skt),
         true <- ClubMembers.member?(user.id, club_id),
         {:ok, _user} <- Accounts.join_chat_topic(user, club_id, chapter) do
      socket = skt
      |> assign(:logged_user_id, user.id)
      |> assign(:topic_id, {club_id, chapter})

      send(self(), :after_join)

      {:ok, socket}
    else
      _error -> {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("load", payload, skt) do
    with topic <- skt.topic,
         user when not is_nil(user) <- GSocket.current_resource(skt),
         messages <- Message.load_from(topic, payload) do
      inform_messages(messages, skt)
    end

    {:noreply, skt}
  end

  def handle_in("shout", payload, skt) do
    with topic <- skt.topic,
         user when not is_nil(user) <- GSocket.current_resource(skt),
         {:ok, message} <- Message.commit(user, topic, payload) do
      spawn(fn -> Notifier.perform(skt, message) end)

      broadcast(skt, "shout", message_to_payload(message))
    end

    {:noreply, skt}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.logged_user_id, %{
      online_at: inspect(System.system_time(:second))
    })

    # socket.topic
    # |> Bookclub.Chat.Message.get_messages()
    # |> inform_messages(socket)

    {:noreply, socket}
  end

  defp inform_messages(messages, socket) do
    Enum.each(messages, fn message ->
      push(socket, "shout", message_to_payload(message))
    end)
  end

  defp message_to_payload(message) do
    %{
      id: message.id,
      user_id: message.user_id,
      user_display_name: message.user_display_name,
      text: message.text,
      inserted_at: message.inserted_at,
      updated_at: message.updated_at,
      checksum: message.checksum
    }
  end
end
