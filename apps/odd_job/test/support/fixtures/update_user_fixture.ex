defmodule OddJobTest.Fixtures.UpdateUserFixture do
  @moduledoc false

  alias __MODULE__.Generators

  def valid() do
    Generators.update_user()
    |> Enum.take(1)
    |> hd()
  end

  defmodule Generators do
    require ExUnitProperties

    alias OddJob.Accounts.Commands.UpdateUser
    alias OddJobTest.Fixtures.{UserFixture, CreateUserFixture}

    import UserFixture.Generators, only: [user: 0]
    import CreateUserFixture.Generators, only: [username: 0, password: 0, permissions: 0]

    def update_user() do
      ExUnitProperties.gen all(
                             user <- user(),
                             username <- username(),
                             username != user.username,
                             password <- password(),
                             Bcrypt.verify_pass(password, user.password_hash) != true,
                             permissions <- permissions()
                           ) do
        UpdateUser.new(user, %{
          "username" => username,
          "password" => password,
          "permissions" => permissions
        })
      end
    end
  end
end
