defmodule OddJob.Accounts.Commands.CreateUser do
  defstruct [:username, :password, :permissions]

  alias OddJob.Accounts.User

  def new(username, password, permissions) do
    %__MODULE__{
      username: String.downcase(username),
      password: password,
      permissions: permissions
    }
  end

  defdelegate execute(cmd), to: User, as: :create
end
