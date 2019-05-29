defmodule BookclubWeb.UserSocketTest do
  use BookclubWeb.ChannelCase, async: true

  alias Bookclub.Auth.Guardian, as: AppGuardian
  alias BookclubWeb.UserSocket
  alias Bookclub.Test.Suport.Fixtures
  alias Guardian.Phoenix.Socket, as: GSocket

  describe "Connection" do
    test "Authenticates with a valid JTW." do
      user = Fixtures.user_fixture()
      {:ok, token, _} = AppGuardian.encode_and_sign(user, %{}, token_type: :access)

      assert {:ok, socket} = connect(UserSocket, %{"token" => token})
      assert GSocket.current_resource(socket) == user
    end

    test "Fails with a invalid JTW." do
      assert :error = connect(UserSocket, %{"token" => "foo"})
    end

    test "Fails with a missing JTW." do
      assert :error = connect(UserSocket, %{})
    end
  end
end
