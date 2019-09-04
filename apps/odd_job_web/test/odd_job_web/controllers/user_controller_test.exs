defmodule OddJobWeb.UserControllerTest do
  use OddJobWeb.ConnCase

  alias OddJob.Accounts.User
  alias OddJobTest.Fixtures.{UpdateUserFixture, UserFixture, CreateUserFixture}

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt(:reader)}")
        |> get(Routes.user_path(conn, :index))

      users = json_response(conn, 200)["data"]
      assert is_list(users)
    end
  end

  describe "create user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, create_user: create_user} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt(:default)}")
        |> post(Routes.user_path(conn, :create), user: create_user)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => _id,
               "password_hash" => password_hash,
               "permissions" => permissions,
               "username" => username
             } = json_response(conn, 200)["data"]

      assert is_integer(id)
      assert Bcrypt.verify_pass(create_user.password, password_hash)
      assert username == create_user.username
      assert permissions == create_user.permissions
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt(:default)}")
        |> post(Routes.user_path(conn, :create), user: %{"username" => ""})

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:update_user]

    test "renders user when data is valid", %{
      conn: conn,
      user: %User{id: id} = user,
      update_attrs: update_attrs
    } do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt(:default)}")
        |> put(Routes.user_path(conn, :update, user),
          user: Map.put(update_attrs, "id", user.id)
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "password_hash" => password_hash,
               "permissions" => permissions,
               "username" => username
             } = json_response(conn, 200)["data"]

      assert id == user.id
      assert Bcrypt.verify_pass(update_attrs["password"], password_hash)
      assert username == update_attrs["username"]
      assert permissions == update_attrs["permissions"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn =
        conn
        |> put_req_header("authorization", "bearer #{jwt(:default)}")
        |> put(Routes.user_path(conn, :update, user),
          user: %{"id" => user.id, "username" => ""}
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 401 when no token", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: user)

      assert json_response(conn, 401)["message"] == "unauthenticated"
    end

    test "returns 401 when no write permission", %{
      conn: conn,
      user: user,
      update_attrs: update_attrs
    } do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt(:reader)}")
        |> put(Routes.user_path(conn, :update, user),
          user: Map.put(update_attrs, "id", user.id)
        )

      assert json_response(conn, 401)["message"] == "unauthorized"
    end
  end

  describe "delete user" do
    setup [:user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer #{jwt(:default)}")
        |> delete(Routes.user_path(conn, :delete, user))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp user(_) do
    user = UserFixture.valid()
    {:ok, user: user}
  end

  defp create_user(_) do
    create_user = CreateUserFixture.valid() |> Map.from_struct()
    {:ok, create_user: create_user}
  end

  defp jwt(:default) do
    user = UserFixture.valid()

    {:ok, jwt, _full_claims} =
      OddJobWeb.Guardian.encode_and_sign(user, %{}, permissions: user.permissions)

    jwt
  end

  defp jwt(:reader) do
    {:ok, user} =
      CreateUserFixture.valid(permissions: %{default: [:read_users]})
      |> OddJob.Accounts.Commands.CreateUser.execute()

    {:ok, jwt, _full_claims} =
      OddJobWeb.Guardian.encode_and_sign(user, %{}, permissions: user.permissions)

    jwt
  end

  defp update_user(_) do
    update_user = UpdateUserFixture.valid()
    {:ok, user: update_user.user, update_attrs: update_user.update_attrs}
  end
end
