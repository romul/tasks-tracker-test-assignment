defmodule TasksTrackerWeb.Plugs.EnsureRolePlug do
  @moduledoc """
  This plug ensures that a user has a particular role.

  ## Example

      plug TasksTrackerWeb.Plugs.EnsureRolePlug, [:driver, :manager]

      plug TasksTrackerWeb.Plugs.EnsureRolePlug, :manager

  """
  import Plug.Conn, only: [halt: 1, put_status: 2]

  alias Plug.Conn
  alias Pow.Plug

  @doc false
  @spec init(any()) :: any()
  def init(config), do: config

  @doc false
  @spec call(Conn.t(), atom() | binary() | [atom()] | [binary()]) :: Conn.t()
  def call(conn, roles) do
    conn
    |> Plug.current_user()
    |> has_role?(roles)
    |> maybe_unauthorized(conn)
  end

  defp has_role?(nil, _roles), do: false
  defp has_role?(user, roles) when is_list(roles), do: Enum.any?(roles, &has_role?(user, &1))
  defp has_role?(user, role) when is_atom(role), do: has_role?(user, Atom.to_string(role))
  defp has_role?(%{role: role}, role), do: true
  defp has_role?(_user, _role), do: false

  defp maybe_unauthorized(true, conn), do: conn

  defp maybe_unauthorized(_any, conn) do
    conn
    |> put_status(:unauthorized)
    |> Phoenix.Controller.json(%{"result" => "error", "errors" => ["Unauthorized Access"]})
    |> halt()
  end
end
