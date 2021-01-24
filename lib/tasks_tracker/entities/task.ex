defmodule TasksTracker.Task do
  use Ecto.Schema
  import Ecto.Changeset
  alias TasksTracker.User

  @supported_states ~w(new assigned done)

  schema "tasks" do
    field :caption, :string
    field :delivery_point, Geo.PostGIS.Geometry
    field :pickup_point, Geo.PostGIS.Geometry
    field :state, :string
    field :distance_to_driver, :float, virtual: true

    belongs_to(:driver, User)
    belongs_to(:manager, User)

    timestamps()
  end

  @doc false
  def changeset_to_create(task, %User{role: "manager", id: manager_id}, attrs) do
    task
    |> cast(attrs, [:caption, :state, :pickup_point, :delivery_point])
    |> put_change(:manager_id, manager_id)
    |> put_change(:state, "new")
    |> validate_required([:caption, :pickup_point, :delivery_point])
  end

  @doc false
  def changeset_to_change_state(task, attrs) do
    task
    |> cast(attrs, [:state, :driver_id])
    |> validate_inclusion(:state, @supported_states)
    |> validate_required([:state])
  end
end
