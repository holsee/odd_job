defmodule OddJob.AccountsTest do
  use OddJob.DataCase

  alias OddJob.Accounts

  describe "users" do
    alias OddJob.Accounts.User
    alias OddJob.Accounts.Commands.CreateUser
    alias OddJobTest.Fixtures.{UserFixture, CreateUserFixture, UpdateUserFixture}

    test "list_users/0 returns all users" do
      user = UserFixture.valid()

      assert Enum.any?(Accounts.list_users(), fn usr ->
               usr.username == user.username and
                 usr.password_hash == user.password_hash and
                 user.permissions == user.permissions
             end)
    end

    test "get_user!/1 returns the user with given id" do
      user = UserFixture.valid()
      assert Accounts.get_user!(user.id) == user
    end

    test "get_user_by_username_and_password" do
      password = "a_well_known_password"

      {:ok, user} = CreateUserFixture.valid(password: password) |> CreateUser.execute()

      assert {:ok, user} = Accounts.get_user_by_username_and_password(user.username, password)
    end

    test "create_user/1 with valid data creates a user" do
      username = CreateUserFixture.username()
      password = CreateUserFixture.password()
      permissions = CreateUserFixture.permissions()
      assert {:ok, %User{} = user} = Accounts.create_user(username, password, permissions)
      assert user.username == String.downcase(username)
      assert user.password == nil
      assert Bcrypt.verify_pass(password, user.password_hash)
      assert user.permissions == permissions
    end

    test "create_user/1 should downcase username" do
      username = CreateUserFixture.username() |> String.upcase()
      password = CreateUserFixture.password()
      permissions = CreateUserFixture.permissions()
      assert {:ok, %User{} = user} = Accounts.create_user(username, password, permissions)
      assert user.username == String.downcase(username)
      assert user.password == nil
      assert Bcrypt.verify_pass(password, user.password_hash)
      assert user.permissions == permissions
    end

    test "create_user/1 with invalid data returns error changeset when passed empty username" do
      invalid_username = CreateUserFixture.username(:invalid, :empty)
      password = CreateUserFixture.password()
      permissions = CreateUserFixture.permissions()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(invalid_username, password, permissions)
    end

    test "create_user/1 with invalid data returns error changeset when passed too short username" do
      invalid_username = CreateUserFixture.username(:invalid, :too_short)
      password = CreateUserFixture.password()
      permissions = CreateUserFixture.permissions()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(invalid_username, password, permissions)
    end

    test "create_user/1 with invalid data returns error changeset when passed too long username" do
      invalid_username = CreateUserFixture.username(:invalid, :too_long)
      password = CreateUserFixture.password()
      permissions = CreateUserFixture.permissions()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(invalid_username, password, permissions)
    end

    test "create_user/1 with invalid data returns error changeset when passed no password" do
      username = CreateUserFixture.username()
      invalid_password = CreateUserFixture.password(:invalid, :empty)
      permissions = CreateUserFixture.permissions()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(username, invalid_password, permissions)
    end

    test "create_user/1 with invalid data returns error changeset when passed too short password" do
      username = CreateUserFixture.username()
      invalid_password = CreateUserFixture.password(:invalid, :too_short)
      permissions = CreateUserFixture.permissions()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(username, invalid_password, permissions)
    end

    test "create_user/1 with invalid data returns error changeset when passed too long password" do
      username = CreateUserFixture.username()
      invalid_password = CreateUserFixture.password(:invalid, :too_long)
      permissions = CreateUserFixture.permissions()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.create_user(username, invalid_password, permissions)
    end

    test "update_user/2 with valid data updates the user" do
      update_user = UpdateUserFixture.valid()

      assert {:ok, %User{} = user} =
               Accounts.update_user(update_user.user, update_user.update_attrs)

      assert user.username == update_user.update_attrs["username"]
      assert user.password == nil
      assert Bcrypt.verify_pass(update_user.update_attrs["password"], user.password_hash)
      assert user.permissions == update_user.update_attrs["permissions"]
    end

    test "update_user/2 should update password" do
      user = UserFixture.valid()

      update_attrs = %{
        "password" => CreateUserFixture.password()
      }

      assert {:ok, user} = Accounts.update_user(user, update_attrs)
      assert Bcrypt.verify_pass(update_attrs["password"], user.password_hash)
    end

    test "update_user/2 should return error changeset when passed invalid data" do
      user = UserFixture.valid()

      invalid_attrs = %{
        "username" => CreateUserFixture.username(:invalid, :empty),
        "password" => CreateUserFixture.password(:invalid, :empty),
        "permissions" => CreateUserFixture.permissions()
      }

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = UserFixture.valid()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end
  end
end
