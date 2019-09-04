defmodule OddJobWeb.AuthControllerTest do
  use OddJobWeb.ConnCase

  alias OddJobTest.Fixtures.{CreateUserFixture}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "identity_callback" do
    test "should return token when passed valid credentials", %{conn: conn} do
      # Create new user
      password = "1234567890"

      {:ok, user} =
        CreateUserFixture.valid(password: password)
        |> OddJob.Accounts.Commands.CreateUser.execute()

      credentials = %{username: user.username, password: password}
      conn = post(conn, Routes.auth_path(conn, :identity_callback), user: credentials)
      assert %{"token" => jwt} = json_response(conn, 200)
      assert {:ok, ^user, _claims} = OddJobWeb.Guardian.resource_from_token(jwt)
    end
  end
end
