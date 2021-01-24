defmodule TasksTrackerWeb.Plugs.AuthTokenPlug do
  import Plug.Conn

  @moduledoc """
  A plug that checks for presence of a simple token for authentication
  """
  @behaviour Plug
  def init(opts), do: opts

  def call(conn, _opts) do
    token = get_auth_header(conn) |> String.replace(~r/Bearer.*?\s+/, "")
    user = TasksTracker.Users.get_user_by(token: token)

    if user do
      conn
      |> Pow.Plug.assign_current_user(user, Pow.Plug.fetch_config(conn))
    else
      conn
      |> put_resp_content_type("application/json")
      |> put_status(:unauthorized)
      |> Phoenix.Controller.json(%{"result" => "error", "errors" => ["Unauthorized Access"]})
      |> halt
    end
  end

  defp get_auth_header(conn) do
    case get_req_header(conn, "authorization") do
      [val | _] -> val
      _ -> ""
    end
  end
end
