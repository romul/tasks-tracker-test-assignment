defmodule TasksTrackerWeb.TaskController do
  use TasksTrackerWeb, :controller
  alias TasksTracker.Tasks
  # https://postgis.net/docs/postgis_usage.html#spatial_ref_sys
  @srid 4326

  plug EnsureRolePlug, [:driver, :manager] when action in [:index]
  plug EnsureRolePlug, [:manager] when action in [:create, :delete]
  plug EnsureRolePlug, [:driver] when action in [:pick, :finish]

  # available tasks for a driver
  def index(conn, %{"lat" => lat, "lng" => lng}) do
    driver_location = %Geo.Point{coordinates: {lng, lat}, srid: @srid}
    tasks = Tasks.list_tasks_nearest_to(driver_location)

    render(conn, "index.json", tasks: tasks)
  end

  # tasks picked by the driver
  def index(%{assigns: %{current_user: %{role: "driver"}}} = conn, _) do
    driver = Pow.Plug.current_user(conn)
    tasks = Tasks.list_tasks_picked_by(driver)

    render(conn, "index.json", tasks: tasks)
  end

  # tasks created by the manager
  def index(%{assigns: %{current_user: %{role: "manager"}}} = conn, _) do
    manager = Pow.Plug.current_user(conn)
    tasks = Tasks.list_tasks_created_by(manager)

    render(conn, "index.json", tasks: tasks)
  end

  def create(conn, params) do
    manager = Pow.Plug.current_user(conn)

    case Tasks.create_task(manager, prepare_geo_points(params)) do
      {:ok, _task} ->
        respond_created(conn)

      {:error, %Ecto.Changeset{} = changeset} ->
        respond_bad_request(conn, changeset_errors_to_list(changeset))
    end
  end

  def delete(conn, %{"id" => id}) do
    case Tasks.delete_task(id) do
      :ok -> respond_ok(conn)
      :error -> respond_bad_request(conn, ["task ##{id} couldn't be deleted"])
    end
  end

  def pick(conn, %{"id" => id}) do
    update(conn, %{"id" => id}, &Tasks.pick_task/2)
  end

  def finish(conn, %{"id" => id}) do
    update(conn, %{"id" => id}, &Tasks.finish_task/2)
  end

  defp update(conn, %{"id" => id}, update_fn) do
    driver = Pow.Plug.current_user(conn)

    case id |> Tasks.get_task() |> update_fn.(driver) do
      {:ok, _task} ->
        respond_ok(conn)

      nil ->
        respond_not_found(conn, ["task ##{id} couldn't be found"])

      {:error, %Ecto.Changeset{} = changeset} ->
        respond_bad_request(conn, changeset_errors_to_list(changeset))

      {:error, error} ->
        respond_bad_request(conn, [error])
    end
  end

  defp prepare_geo_points(%{"pickup_point" => pp, "delivery_point" => dp} = params) do
    params
    |> Map.put("pickup_point", %Geo.Point{coordinates: {pp["lng"], pp["lat"]}, srid: @srid})
    |> Map.put("delivery_point", %Geo.Point{coordinates: {dp["lng"], dp["lat"]}, srid: @srid})
  end
  defp prepare_geo_points(params), do: params
end
