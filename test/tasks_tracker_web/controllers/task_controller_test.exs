defmodule TasksTrackerWeb.TaskControllerTest do
  use TasksTrackerWeb.ConnCase
  alias TasksTracker.Tasks

  describe "Manager" do
    setup do
      manager = insert(:manager)

      [
        conn: build_conn() |> Plug.Conn.put_req_header("authorization", "Bearer #{manager.token}"),
        manager: manager,
        payload: %{
          "caption" => "Msk->Tver",
          "pickup_point" => %{"lat" => "55.754", "lng" => "37.623"},
          "delivery_point" => %{"lat" => "56.86", "lng" => "35.91"}
        }
      ]
    end

    test "can create tasks with two geo locations pickup and delivery", ctx do
      conn = post(ctx.conn, Routes.api_task_path(ctx.conn, :create), ctx.payload)
      assert %{"result" => "ok"} = json_response(conn, :created)
    end

    test "can't create tasks without geo locations pickup and delivery", ctx do
      conn = post(ctx.conn, Routes.api_task_path(ctx.conn, :create), %{"caption" => "Test"})

      assert %{
               "errors" => ["pickup_point can't be blank", "delivery_point can't be blank"],
               "result" => "error"
             } = json_response(conn, :bad_request)
    end

    test "can delete task", ctx do
      task = insert(:task)
      conn = delete(ctx.conn, Routes.api_task_path(ctx.conn, :delete, task.id))

      assert %{"result" => "ok"} = json_response(conn, :ok)
    end

    test "can't change task status", ctx do
      task = insert(:task)
      conn = put(ctx.conn, Routes.api_task_path(ctx.conn, :pick, task.id), %{})

      assert %{"result" => "error"} = json_response(conn, :unauthorized)
    end

    test "can get list of tasks created by him/her", ctx do
      another_manager = insert(:manager, full_name: "Fake Manager")
      t1 = insert(:task, manager_id: ctx.manager.id)
      _t2 = insert(:task, manager_id: another_manager.id)
      _t3 = insert(:task, manager_id: nil)

      conn = get(ctx.conn, Routes.api_task_path(ctx.conn, :index))
      assert %{"result" => "ok", "tasks" => [task]} = json_response(conn, :ok)

      assert t1.id == task["id"]
    end
  end


  describe "Driver" do
    setup do
      driver = insert(:driver)

      [
        conn: build_conn() |> Plug.Conn.put_req_header("authorization", "Bearer #{driver.token}"),
        driver: driver
      ]
    end

    test "can get the list of tasks nearby (sorted by distance) by sending his current location", ctx do
      t1 = insert(:task, pickup_point: %Geo.Point{coordinates: {37.622, 55.753}, srid: 4326})
      t2 = insert(:task, pickup_point: %Geo.Point{coordinates: {37.623, 55.754}, srid: 4326})
      t3 = insert(:task, pickup_point: %Geo.Point{coordinates: {37.624, 55.755}, srid: 4326})

      conn = get(ctx.conn, Routes.api_task_path(ctx.conn, :index, %{"lat" => "55.753", "lng" => "37.622"}))
      assert %{"result" => "ok", "tasks" => tasks} = json_response(conn, :ok)

      assert [t1.id, t2.id, t3.id] == Enum.map(tasks, fn(t) -> t["id"] end)

      distances = Enum.map(tasks, fn(t) -> t["distance"] end)
      assert Enum.sort(distances) == distances
    end

    test "can get only unassigned tasks by location", ctx do
      another_driver = insert(:driver, full_name: "Fake Driver")
      t1 = insert(:task)
      _t2 = insert(:task, driver_id: another_driver.id)

      conn = get(ctx.conn, Routes.api_task_path(ctx.conn, :index, %{"lat" => "55.753", "lng" => "37.622"}))
      assert %{"result" => "ok", "tasks" => [task]} = json_response(conn, :ok)

      assert t1.id == task["id"]
    end

    test "can get list of tasks assigned to him/her", ctx do
      another_driver = insert(:driver, full_name: "Fake Driver")
      t1 = insert(:task, driver_id: ctx.driver.id)
      _t2 = insert(:task, driver_id: another_driver.id)
      _t3 = insert(:task, driver_id: nil)

      conn = get(ctx.conn, Routes.api_task_path(ctx.conn, :index))
      assert %{"result" => "ok", "tasks" => [task]} = json_response(conn, :ok)

      assert t1.id == task["id"]
    end

    test "can pick an unassigned task", ctx do
      task = insert(:task)
      conn = put(ctx.conn, Routes.api_task_path(ctx.conn, :pick, task.id), %{})

      assert %{"result" => "ok"} = json_response(conn, :ok)

      assert Tasks.get_task(task.id).state == "assigned"
    end

    test "can't pick an assigned task", ctx do
      task = insert(:task, driver_id: insert(:driver).id)
      conn = put(ctx.conn, Routes.api_task_path(ctx.conn, :pick, task.id), %{})

      assert %{"result" => "error"} = json_response(conn, :bad_request)
    end

    test "can finish the assigned task", ctx do
      task = insert(:task)
      put(ctx.conn, Routes.api_task_path(ctx.conn, :pick, task.id), %{})
      conn = put(ctx.conn, Routes.api_task_path(ctx.conn, :finish, task.id), %{})

      assert %{"result" => "ok"} = json_response(conn, :ok)

      assert Tasks.get_task(task.id).state == "done"
    end

    test "can't finish an unassigned task", ctx do
      task = insert(:task)
      conn = put(ctx.conn, Routes.api_task_path(ctx.conn, :finish, task.id), %{})

      assert %{"result" => "error"} = json_response(conn, :bad_request)
    end

    test "can't create tasks", ctx do
      conn = post(ctx.conn, Routes.api_task_path(ctx.conn, :create), %{"caption" => "Test"})

      assert %{"result" => "error"} = json_response(conn, :unauthorized)
    end

    test "can't delete tasks", ctx do
      task = insert(:task)
      conn = delete(ctx.conn, Routes.api_task_path(ctx.conn, :delete, task.id))

      assert %{"result" => "error"} = json_response(conn, :unauthorized)
    end
  end
end
