defmodule OddJob.Accounts.User do
  use Ecto.Schema

  require Logger

  alias OddJob.Accounts.Commands.{
    CreateUser,
    UpdateUser,
    DeleteUser
  }

  import Ecto.Changeset
  alias __MODULE__

  schema "users" do
    field :password_hash, :string
    field :permissions, :map
    field :username, :string

    # Add a virtual attribute to hold plain text passwords.
    field :password, :string, virtual: true

    timestamps()
  end

  def create(%CreateUser{} = cmd) do
    cmd
    |> changeset()
    |> OddJob.Repo.insert()
  end

  def update(%UpdateUser{} = cmd) do
    cmd
    |> changeset()
    |> OddJob.Repo.update()
  rescue
    Ecto.StaleEntryError ->
      Logger.error("Failed to update user id `#{cmd.user.id}` due to `Ecto.StaleEntryError`.")
      :not_found
  end

  def delete(%DeleteUser{user: user}) do
    OddJob.Repo.delete(user)
  rescue
    Ecto.StaleEntryError ->
      Logger.error("Failed to delete user id `#{user.id}` due to `Ecto.StaleEntryError`.")
      :not_found
  end

  @doc false
  def changeset(%CreateUser{} = cmd) do
    attrs = Map.from_struct(cmd)

    %User{}
    |> cast(attrs, [:username, :password, :permissions])
    |> validate_required([:username, :password, :permissions])
    |> validate_length(:username, min: 3, max: 64)
    |> validate_length(:password, min: 10, max: 64)
    |> unique_constraint(:username)
    |> put_password_hash()
  end

  def changeset(%UpdateUser{} = cmd) do
    cmd.user
    |> cast(cmd.update_attrs, [:username, :password, :permissions])
    |> validate_required([:username, :password, :permissions])
    |> validate_length(:username, min: 3, max: 64)
    |> validate_length(:password, min: 10, max: 64)
    |> unique_constraint(:username)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        changeset
        |> change(Bcrypt.add_hash(password))

      _ ->
        changeset
    end
  end
end
