defmodule TasksTracker.TasksTest do
  use TasksTracker.DataCase
  alias TasksTracker.{Task, Tasks, Users}

  setup do
    [
      driver: insert(:driver),
      manager: insert(:manager)
    ]
  end

  describe "create_task/2" do
    test "returns an error when some required attributes are missing", ctx do
      assert get_tasks_count() == 0
      {:error, _} = Tasks.create_task(ctx.manager, task_params(%{delivery_point: nil}))
      assert get_tasks_count() == 0
    end

    test "creates a task when all params present", ctx do
      assert {:ok, %Task{}} = Tasks.create_task(ctx.manager, task_params())
    end
  end

  describe "get tasks list" do
    test "list_tasks_nearest_to/1", ctx do
      driver_location = %Geo.Point{coordinates: {35.9119, 56.85961}, srid: 4326}

      {:ok, task1} =
        Tasks.create_task(
          ctx.manager,
          task_params(%{pickup_point: %Geo.Point{coordinates: {35.9111, 56.85961}, srid: 4326}})
        )

      {:ok, task2} =
        Tasks.create_task(
          ctx.manager,
          task_params(%{pickup_point: %Geo.Point{coordinates: {35.9112, 56.85961}, srid: 4326}})
        )

      assert [task2.id, task1.id] ==
               Tasks.list_tasks_nearest_to(driver_location) |> Enum.map(& &1.id)
    end

    test "list_tasks_created_by/1", ctx do
      {:ok, task} = Tasks.create_task(ctx.manager, task_params())

      assert [task] == Tasks.list_tasks_created_by(ctx.manager)
    end

    test "list_tasks_picked_by/1", ctx do
      {:ok, task} = Tasks.create_task(ctx.manager, task_params())
      {:ok, task} = Tasks.pick_task(task, ctx.driver)

      assert [task] == Tasks.list_tasks_picked_by(ctx.driver)
    end
  end

  describe "pick_task/2" do
    setup(ctx) do
      {:ok, task} = Tasks.create_task(ctx.manager, task_params())

      [task: task]
    end

    test "success when pick unassigned task", ctx do
      assert {:ok, %{state: "assigned"}} = Tasks.pick_task(ctx.task, ctx.driver)
    end

    test "fails when try to pick assigned task", ctx do
      {:ok, task} = Tasks.pick_task(ctx.task, ctx.driver)

      {:ok, another_driver} = Users.create_driver(%{"full_name" => "Fake Driver", "phone" => "+79876543219"})

      assert {:error, "This task already has been picked by another driver"} = Tasks.pick_task(task, another_driver)
    end
  end

  describe "finish_task/2" do
    setup(ctx) do
      {:ok, task} = Tasks.create_task(ctx.manager, task_params())

      [task: task]
    end

    test "success when finish assigned task", ctx do
      assert {:ok, task} = Tasks.pick_task(ctx.task, ctx.driver)

      assert {:ok, %{state: "done"}} = Tasks.finish_task(task, ctx.driver)
    end

    test "fails when try to finish unassigned task", ctx do
      assert {:error, "Transition to this state isn't declared."} = Tasks.finish_task(ctx.task, ctx.driver)
    end
  end
end
