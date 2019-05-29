defmodule Bookclub.Clubs.ClubMembers do
  @moduledoc """
  """

  import Ecto.Query

  alias Bookclub.Repo
  alias Bookclub.Clubs.ClubMember

  def create_club_member(attrs \\ %{}) do
    %ClubMember{}
    |> ClubMember.changeset(attrs)
    |> Repo.insert()
  end

  def join_club!(user, club) do
    create_club_member(%{user_id: user.id, club_id: club.id})
  end

  def join_club(user, club, join_code) do
    with true <- valid_join_code?(club, join_code),
         attrs <- %{user_id: user.id, club_id: club.id},
         {:ok, member} <- create_club_member(attrs) do
      {:ok, member}
    else
      _error -> {:error, :invalid_join_code}
    end
  end

  def leave_club(user, club) do
    case do_leave_club(user.id, club.id) do
      {1, _any} ->
        {:ok, :left}

      _any ->
        {:error, :cant_leave_club}
    end
  end

  def member?(user_id, club_id) do
    Repo.one(from member in ClubMember,
      where: member.user_id == ^user_id,
      where: member.club_id == ^club_id,
      select: fragment("count(*)")) == 1
  end

  defp do_leave_club(user_id, club_id) do
    Repo.delete_all(from(member in ClubMember,
      where: member.user_id == ^user_id,
      where: member.club_id == ^club_id
    ))
  end

  defp valid_join_code?(club, join_code) do
    club.join_code == join_code
  end
end
