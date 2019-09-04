defmodule OddJobWeb.UserController do
  use OddJobWeb, :controller

  alias OddJob.Accounts
  alias OddJob.Accounts.User

  action_fallback OddJobWeb.FallbackController

  plug Guardian.Permissions,
       [ensure: %{default: [:read_users]}] when action in [:index, :show]

  plug Guardian.Permissions,
       [ensure: %{default: [:write_users]}] when action in [:create, :update, :delete]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with username = Map.get(user_params, "username"),
         password = Map.get(user_params, "password"),
         permissions =
           Map.get(user_params, "permissions") || OddJobWeb.Guardian.default_permissions(),
         {:ok, %User{} = user} <- Accounts.create_user(username, password, permissions) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
