defmodule BookclubWeb.ChatRoomChannelTest do
  use BookclubWeb.ChannelCase

  alias Bookclub.{
    Auth.Guardian,
    Test.Suport.Fixtures
  }

  alias BookclubWeb.UserSocket

  describe "Authenticated member" do
    setup do
      user = Fixtures.user_fixture()
      club = Fixtures.club_fixture()
      Bookclub.Clubs.ClubMembers.join_club!(user, club)
      topic = "chat_room:#{club.id}/1"

      {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)

      {:ok,
       user: user,
       club: club,
       topic: topic,
       token: token}
    end

    test "Assigns :topic_id to the socket after joining", c do
      {:ok, socket} = connect(UserSocket, %{"token" => c[:token]})
      {:ok, _, socket} = subscribe_and_join(socket, c[:topic], %{})

      assert socket.assigns.topic_id == {c[:club].id, 1}
    end

    test "Broadcasts a message sent.", c do
      {:ok, socket} = connect(UserSocket, %{"token" => c[:token]})
      {:ok, _, socket} = subscribe_and_join(socket, c[:topic], %{})

      push(socket, "shout", %{"text" => "Hello, Joe."})
      assert_broadcast "shout", %{text: "Hello, Joe."}
    end
  end

  describe "Unauthenticated member" do
    setup do
      user = Fixtures.user_fixture()
      club = Fixtures.club_fixture()
      Bookclub.Clubs.ClubMembers.join_club!(user, club)
      topic = "chat_room:#{club.id}/1"
      token = "foo"

      {:ok,
       user: user,
       club: club,
       topic: topic,
       token: token}
    end

    test "Won't connect.", c do
      assert :error == connect(UserSocket, %{"token" => c[:token]})
    end
  end

  describe "Authenticated guest" do
    setup do
      user = Fixtures.user_fixture()
      club = Fixtures.club_fixture()
      topic = "chat_room:#{club.id}/1"

      {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)

      {:ok,
       user: user,
       club: club,
       topic: topic,
       token: token}
    end

    test "Connects but won't join/subscribe.", c do
      {:ok, socket} = connect(UserSocket, %{"token" => c[:token]})
      assert {:error, %{reason: "unauthorized"}} == subscribe_and_join(socket, c[:topic], %{})
    end
  end
end
