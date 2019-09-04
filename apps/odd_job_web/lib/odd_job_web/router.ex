defmodule OddJobWeb.Router do
  use OddJobWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug OddJobWeb.Plug.AuthAccessPipeline
  end

  scope "/", OddJobWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", OddJobWeb do
    pipe_through :api

    scope "/auth" do
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
      post "/identity/callback", AuthController, :identity_callback
    end

    pipe_through :authenticated

    resources "/users", UserController, except: [:new, :edit]
  end
end
