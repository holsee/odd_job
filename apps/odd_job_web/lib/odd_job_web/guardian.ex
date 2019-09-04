defmodule OddJobWeb.Guardian do
  use Guardian,
    otp_app: :odd_job_web

  use Guardian.Permissions

  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :no_resource_id}
  end

  def resource_from_claims(%{"sub" => sub}) do
    {:ok, OddJob.Accounts.get_user!(sub)}
  end

  def resource_from_claims(_claims) do
    {:error, :no_claims_sub}
  end

  def build_claims(claims, _resource, opts) do
    claims =
      claims
      |> encode_permissions_into_claims!(Keyword.get(opts, :permissions))

    {:ok, claims}
  end

  def default_permissions() do
    Application.get_env(:odd_job_web, __MODULE__)[:permissions]
  end
end

defmodule OddJobWeb.Plug.AuthAccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :odd_job_web

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end

defmodule OddJobWeb.Plug.AuthErrorHandler do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> json(%{message: to_string(type)})
    |> halt()
  end
end
