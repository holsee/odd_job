defmodule OddJobTest.Fixtures.CreateUserFixture do
  @moduledoc false

  alias OddJob.Accounts.Commands.CreateUser
  alias __MODULE__.Generators

  def valid() do
    Generators.create_user()
    |> one()
  end

  def valid(opts \\ []) do
    CreateUser.new(
      opts[:username] || username(),
      opts[:password] || password(),
      opts[:permissions] || permissions()
    )
  end

  def username() do
    Generators.username()
    |> one()
  end

  def username(:invalid, :empty) do
    ""
  end

  def username(:invalid, :too_short) do
    String.duplicate("U", 2)
  end

  def username(:invalid, :too_long) do
    String.duplicate("X", 65)
  end

  def password() do
    Generators.password()
    |> one()
  end

  def password(:invalid, :empty) do
    ""
  end

  def password(:invalid, :too_short) do
    String.duplicate("P", 9)
  end

  def password(:invalid, :too_long) do
    String.duplicate("X", 65)
  end

  def permissions() do
    Generators.permissions()
    |> one()
  end

  defp one(stream) do
    stream
    |> Enum.take(1)
    |> hd()
  end

  defmodule Generators do
    require ExUnitProperties

    def create_user() do
      ExUnitProperties.gen all(
                             username <- username(),
                             password <- password(),
                             permissions <- permissions()
                           ) do
        CreateUser.new(username, password, permissions)
      end
    end

    def username() do
      StreamData.string(:alphanumeric, min_length: 3, max_length: 64)
    end

    def password() do
      StreamData.string(:alphanumeric, min_length: 10, max_length: 64)
    end

    def permissions() do
      StreamData.constant(%{"default" => ["read_users", "write_users"]})
    end
  end
end
