defmodule Bookclub.AccountsTest do
  use Bookclub.DataCase, async: true

  alias Bookclub.Test.Suport.Fixtures
  alias Bookclub.Accounts

  @moduletag :accounts

  describe "users" do
    alias Bookclub.Accounts.User

    @update_attrs %{first_name: "new first_name", last_name: "new last_name"}
    @invalid_attrs %{first_name: nil, last_name: nil, email: nil}

    test "list_users/0 returns all users" do
      user = Fixtures.user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = Fixtures.user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(:api_changeset, Fixtures.user_data())
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(:api_changeset, @invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = Fixtures.user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(:api_changeset, user, @update_attrs)
      assert user.last_name == "new last_name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = Fixtures.user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(:api_changeset, user, @invalid_attrs)

      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = Fixtures.user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "get_display_name/1 gives the first and last name of a user" do
      user = Fixtures.user_fixture()
      assert {:ok, "Example Example"} = User.get_display_name(user.id)
    end

    test "get_display_name/1 fails when user is inexistent" do
      assert {:error, :not_found} = User.get_display_name(1)
    end
  end
end
