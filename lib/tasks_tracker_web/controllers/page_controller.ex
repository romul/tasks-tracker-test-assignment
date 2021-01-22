defmodule TasksTrackerWeb.PageController do
  use TasksTrackerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
