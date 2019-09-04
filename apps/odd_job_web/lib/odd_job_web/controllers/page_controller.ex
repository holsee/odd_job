defmodule OddJobWeb.PageController do
  use OddJobWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
