defmodule OddJob.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias OddJob.Repo

  alias OddJob.Accounts.Commands.{
    CreateUser,
    UpdateUser,
    DeleteUser
  }

  alias OddJob.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by username and password.
  Returns error tuple when user does not exist or username/password are invalid.
  `Bcrypt.check_pass/2` prevents user enumeration by default.

  ## Examples

      iex> get_user_by_username_and_password(username, password)
      {:ok, %User{}}

      iex> get_user_by_username_and_password(username, password)
      {:error, :unauthorised}

  """
  def get_user_by_username_and_password(username, password)
      when is_nil(username) or is_nil(password) do
    {:error, :invalid}
  end

  def get_user_by_username_and_password(username, password) do
    with %User{} = user <- Repo.get_by(User, username: String.downcase(username)),
         {:ok, ^user} <- Bcrypt.check_pass(user, password) do
      {:ok, user}
    else
      _ ->
        {:error, :unauthorised}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(username, password, permissions)
      {:ok, %User{}}

      iex> create_user(username, password, permissions)
      {:error, %Ecto.Changeset{}}

  """
  def create_user(username, password, permissions) do
    CreateUser.new(username, password, permissions)
    |> CreateUser.execute()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user_id, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(user, update_attrs) do
    UpdateUser.new(user, update_attrs)
    |> UpdateUser.execute()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    DeleteUser.new(user)
    |> DeleteUser.execute()
  end
end
