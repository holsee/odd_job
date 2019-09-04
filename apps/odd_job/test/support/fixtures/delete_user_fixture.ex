defmodule OddJobTest.Fixtures.DeleteUserFixture do
  @moduledoc false

  alias __MODULE__.Generators

  def valid() do
    Generators.delete_user()
    |> Enum.take(1)
    |> hd()
  end

  defmodule Generators do
    require ExUnitProperties

    alias OddJob.Accounts.Commands.DeleteUser
    alias OddJobTest.Fixtures.UserFixture
    import UserFixture.Generators, only: [user: 0]

    def delete_user() do
      ExUnitProperties.gen all(user <- user()) do
        DeleteUser.new(user)
      end
    end
  end
end
