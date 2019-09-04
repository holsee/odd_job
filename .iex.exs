seed = fn ->
  OddJob.Accounts.create_user("admin", "1234567890", %{default: [:read_users, :write_users]})
  OddJob.Accounts.create_user("reader", "1234567890", %{default: [:read_users, :write_users]})
end
