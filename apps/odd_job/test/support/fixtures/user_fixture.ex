defmodule OddJobTest.Fixtures.UserFixture do
  @moduledoc false

  alias __MODULE__.Generators

  def valid() do
    Generators.user()
    |> Enum.take(1)
    |> hd()
  end

  defmodule Generators do
    require ExUnitProperties

    alias OddJob.Accounts.Commands.CreateUser
    alias OddJobTest.Fixtures.CreateUserFixture
    import CreateUserFixture.Generators, only: [create_user: 0]

    def user() do
      ExUnitProperties.gen all(create_user <- create_user()) do
        {:ok, user} = CreateUser.execute(create_user)
        user
      end
    end
  end
end
