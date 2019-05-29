defmodule Bookclub.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Bookclub.Helpers
  alias Bookclub.Repo

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:type, :integer, default: 1)
    field(:photo_url, :string)
    field(:phone_number, :string)
    field(:date_of_birth, :date)
    field(:expo_push_tokens, {:array, :string})
    field(:joined_topics, {:array, :string})
    field(:metadata, :map)
    field(:reset_token, :string)
    field(:reset_token_birth, :naive_datetime)

    timestamps()
  end

  @allowed_on_admin [
    :first_name,
    :last_name,
    :email,
    :password,
    :type,
    :photo_url,
    :phone_number,
    :date_of_birth
  ]

  @required_on_creating_by_admin [
    :first_name,
    :last_name,
    :email,
    :phone_number,
    :password,
    :type
  ]

  @required_on_updating_by_admin [:first_name, :last_name, :email, :phone_number, :type]

  @allowed_on_api [
    :first_name,
    :last_name,
    :email,
    :password,
    :photo_url,
    :phone_number,
    :date_of_birth,
    :expo_push_tokens,
    :joined_topics,
    :metadata
  ]

  @internal [
    :first_name,
    :last_name,
    :email,
    :password,
    :photo_url,
    :phone_number,
    :date_of_birth,
    :expo_push_tokens,
    :joined_topics,
    :metadata,
    :reset_token,
    :reset_token_birth
  ]

  @required_on_creating_by_api [:first_name, :last_name, :email, :password, :phone_number]
  @required_on_updating_by_api [:first_name, :last_name, :email, :phone_number]

  def types do
    %{
      regular: %{label: "Regular", id: 1},
      admin: %{label: "Admin", id: 2}
    }
  end

  def changeset(changeset_type, user, attrs \\ %{})

  def changeset(:create_by_admin, user, attrs) do
    user
    |> cast(attrs, @allowed_on_admin)
    |> validate_required(@required_on_creating_by_admin)
    |> common()
  end

  def changeset(:update_by_admin, user, attrs) do
    user
    |> cast(attrs, @allowed_on_admin)
    |> validate_required(@required_on_updating_by_admin)
    |> common()
  end

  def changeset(:create_by_api, user, attrs) do
    user
    |> cast(attrs, @allowed_on_api)
    |> validate_required(@required_on_creating_by_api)
    |> common()
  end

  def changeset(:update_by_api, user, attrs) do
    user
    |> cast(attrs, @allowed_on_api)
    |> validate_required(@required_on_updating_by_api)
    |> common()
  end

  def changeset(:internal, user, attrs) do
    cast(user, attrs, @internal)
  end

  def get_display_name(id) do
    with user when not is_nil(user) <- Repo.one(display_name_query(id)) do
      {:ok, "#{user.first_name} #{user.last_name}"}
    else
      nil -> {:error, :not_found}
      err -> err
    end
  end

  defp common(changeset) do
    changeset
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:phone_number)
    |> put_pass_hash()
    |> valid_phone_number()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    changeset
    |> change(Comeonin.Bcrypt.add_hash(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp valid_phone_number(
         %Ecto.Changeset{valid?: true, changes: %{phone_number: phone_number}} = changeset
       ) do
    changeset
    |> change(phone_number: Helpers.to_only_numbers(phone_number))
  end

  defp valid_phone_number(changeset), do: changeset

  defp display_name_query(id) do
    from(user in __MODULE__,
      where: user.id == ^id,
      select: [:first_name, :last_name]
    )
  end
end
