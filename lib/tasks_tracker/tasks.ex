defmodule TasksTracker.Tasks do
  import Ecto.Query
  import Geo.PostGIS
  alias TasksTracker.{Repo, Task, TaskStateMachine, User}

  def get_task(task_id) do
    Task |> Repo.get(task_id)
  end

  def create_task(%User{role: "manager"} = manager, attrs \\ %{}) do
    %Task{}
    |> Task.changeset_to_create(manager, attrs)
    |> Repo.insert()
  end

  def delete_task(task_id) do
    case from(t in Task, where: t.id == ^task_id) |> Repo.delete_all() do
      {1, nil} -> :ok
      _ -> :error
    end
  end

  def list_tasks_nearest_to(point, max_count \\ 10) do
    query =
      from task in Task,
        limit: ^max_count,
        where: is_nil(task.driver_id),
        select: %{task: task, distance: st_distance(task.pickup_point, ^point)},
        order_by: st_distance(task.pickup_point, ^point)

    query
    |> Repo.all()
    |> Enum.map(fn %{task: task, distance: distance} ->
      task |> Map.put(:distance_to_driver, distance)
    end)
  end

  def list_tasks_created_by(%User{role: "manager", id: manager_id}, max_count \\ 10) do
    query =
      from task in Task,
        limit: ^max_count,
        where: task.manager_id == ^manager_id,
        order_by: [desc: :updated_at]

    query |> Repo.all()
  end

  def list_tasks_picked_by(%User{role: "driver", id: driver_id}, max_count \\ 10) do
    query =
      from task in Task,
        limit: ^max_count,
        where: task.driver_id == ^driver_id,
        order_by: [desc: :updated_at]

    query |> Repo.all()
  end

  def pick_task(nil, _), do: nil

  def pick_task(%{driver_id: driver_id} = task, %{id: driver_id}) do
    {:ok, task}
  end

  def pick_task(%{driver_id: driver_id}, _) when driver_id != nil do
    {:error, "This task already has been picked by another driver"}
  end

  def pick_task(task, %User{role: "driver"} = driver) do
    case Machinery.transition_to(task, TaskStateMachine, "assigned") do
      {:ok, upd_task} ->
        task
        |> Task.changeset_to_change_state(%{"driver_id" => driver.id, "state" => upd_task.state})
        |> Repo.update()

      {:error, error} ->
        {:error, error}
    end
  end

  def finish_task(nil, _), do: nil

  def finish_task(task, _driver) do
    case Machinery.transition_to(task, TaskStateMachine, "done") do
      {:ok, upd_task} ->
        task
        |> Task.changeset_to_change_state(%{"state" => upd_task.state})
        |> Repo.update()

      {:error, error} ->
        {:error, error}
    end
  end
end
