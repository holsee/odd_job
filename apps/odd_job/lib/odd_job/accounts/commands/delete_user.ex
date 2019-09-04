defmodule OddJob.Accounts.Commands.DeleteUser do
  defstruct [:user]

  alias OddJob.Accounts.User

  def new(%User{} = user) do
    %__MODULE__{
      user: user
    }
  end

  defdelegate execute(cmd), to: User, as: :delete
end
