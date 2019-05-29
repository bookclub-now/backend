defmodule Bookclub.Clubs do
  @moduledoc """
  The Clubs context.
  """
  alias Bookclub.Repo
  alias Bookclub.Clubs.{Book, Club}

  import Ecto.Query, only: [from: 2]

  @doc """
  Returns the list of clubs.

  ## Examples

      iex> list_clubs()
      [%Club{}, ...]

  """
  def list_clubs do
    Repo.all(Club)
    |> Repo.preload([:book, :user])
  end

  @doc """
  Returns the list of User's clubs.

  ## Examples

      iex> list_user_clubs(user_id: user_id)
      [%Club{}, ...]

  """
  def list_user_clubs(attrs) do
    query =
      from(c in Club,
        join: b in assoc(c, :book),
        left_join: m in assoc(c, :members),
        where: c.user_id == ^attrs[:user_id],
        or_where:
          ^attrs[:user_id] in fragment(
            "SELECT m.user_id FROM club_members m WHERE m.club_id = ?",
            c.id
          ),
        order_by: c.inserted_at,
        select: c,
        preload: [book: b, members: m]
      )

    {:ok, Repo.all(query)}
  end

  @doc """
  Creates a club.

  ## Examples

      iex> create_club(%{field: value})
      {:ok, %Club{}}

      iex> create_club(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_club(attrs \\ %{}) do
    %Club{}
    |> Club.changeset(attrs)
    |> add_join_code()
    |> Repo.insert()
  end

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs \\ %{}) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Finds a book.

  ## Examples

      iex> find_book(field: value)
      {:ok, %Book{}}

      iex> find_book(field: bad_value)
      {:error, nil}

  """
  def find_book(attrs \\ []) do
    case Repo.get_by(Book, attrs) do
      %Book{} = book ->
        {:ok, book}

      _ ->
        {:error, nil}
    end
  end

  def find_club(attrs \\ []) do
    case Repo.get_by(Club, attrs) do
      %Club{} = club ->
        {:ok, club}

      _ ->
        {:error, nil}
    end
  end

  defp add_join_code(%{valid?: true} = cs) do
    Ecto.Changeset.change(cs, join_code: gen_join_code())
  end

  defp add_join_code(changeset) do
    changeset
  end

  defp gen_join_code do
    with length <- Enum.random(12..21),
         bytes <- :crypto.strong_rand_bytes(length),
         hash <- :crypto.hash(:sha, bytes),
         base <- Base.encode16(hash, case: :lower),
         code <- binary_part(base, 0, length) do
      code
    end
  end
end
