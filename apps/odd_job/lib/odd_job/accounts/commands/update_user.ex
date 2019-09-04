defmodule OddJob.Accounts.Commands.UpdateUser do
  defstruct [:user, :update_attrs]

  alias OddJob.Accounts.User

  defguard is_update_attrs(update_attrs) when is_map(update_attrs)

  def new(%User{} = user, update_attrs) when is_update_attrs(update_attrs) do
    %__MODULE__{
      user: user,
      update_attrs: update_attrs
    }
  end

  defdelegate execute(cmd), to: User, as: :update
end
