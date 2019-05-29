defmodule Bookclub.Chat.MessageTest do
  use ExUnit.Case, async: true

  alias Bookclub.Chat.Message, as: Subject
  alias Bookclub.Test.Suport.Fixtures

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bookclub.Repo)
  end

  describe "changeset/2" do
    test "Trim out invalid params." do
      params = Map.from_struct(Fixtures.message_fixture())

      assert true == Subject.changeset(%Subject{}, params).valid?
    end

    test "Validates required params." do
      assert false == Subject.changeset(%Subject{}, %{}).valid?
    end
  end

  describe "commit/3" do
    setup do
      user = Fixtures.user_fixture()
      club = Fixtures.club_fixture()

      payload = %{
        "text" => "Hello, Joe."
      }

      {:ok, user: user, club: club, payload: payload}
    end

    test "Saves a message payload of a given topic.", context do
      topic = "chat_room:#{context[:club].id}/1"
      assert {:ok, _msg} = Subject.commit(context[:user], topic, context[:payload])
    end

    test "Won't commit if it's a bad Club ID topic.", context do
      topic = "chat_room:Foo/1"
      assert {:error, _error} = Subject.
      commit(context[:user], topic, context[:payload])
    end

    test "Won't commit if it's a bad Chapter topic.", context do
      topic = "chat_room:#{context[:club].id}/Foo"
      assert {:error, _error} = Subject.commit(context[:user], topic, context[:payload])
    end

    test "Won't commit if it's a big :text payload.", context do
      topic = "chat_room:#{context[:club].id}/1"

      payload = %{
        "text" => String.duplicate("Hello, Joe. ", 255)
      }

      assert {:error, _error} = Subject.commit(context[:user], topic, payload)
    end

    test "Won't commit if the User is invalid.", context do
      topic = "chat_room:#{context[:club].id}/1"

      payload = %{
        "text" => "Hello, Joe."
      }

      assert {:not_user, _error} = Subject.commit("Foo", topic, payload)
    end
  end

  describe "topic_id/1" do
    test "Formats a channel topic into a Topic ID." do
      assert {:ok, {212, 37}} == Subject.topic_id("chat_room:212/37")
    end

    test "Won't format if it's a bad Club ID topic." do
      assert {:error, _error} = Subject.topic_id("chat_room:Foo/37")
    end

    test "Won't format if it's a bad Chapter topic." do
      assert {:error, _error} = Subject.topic_id("chat_room:212/Foo")
    end
  end

  describe "topic_to_text/1" do
    test "Transforms topic IDs into formatted strings." do
      assert "90/100" == Subject.topic_to_text({90, 100})
    end
  end
end
