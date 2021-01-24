defmodule TasksTrackerWeb.WorkflowTest do
  use TasksTrackerWeb.ConnCase

  setup do
    driver = insert(:driver)
    manager = insert(:manager)
    _ = insert(:task, pickup_point: %Geo.Point{coordinates: {37.62, 55.75}, srid: 4326})
    _ = insert(:task, pickup_point: %Geo.Point{coordinates: {37.63, 55.76}, srid: 4326})

    [
      driver: driver,
      manager: manager,
      driver_conn: build_conn() |> Plug.Conn.put_req_header("authorization", "Bearer #{driver.token}"),
      manager_conn: build_conn() |> Plug.Conn.put_req_header("authorization", "Bearer #{manager.token}")
    ]
  end

  describe "The Main Workflow" do
    setup do
      [
        payload: %{
          "caption" => "Msk->Tver",
          "pickup_point" => %{"lat" => "55.754", "lng" => "37.623"},
          "delivery_point" => %{"lat" => "56.86", "lng" => "35.91"}
        }
      ]
    end

    test "should be successful", ctx do
      # The manager creates a task with location pickup [lat1, long1] and delivery [lat2,long2]
      conn = post(ctx.manager_conn, Routes.api_task_path(ctx.manager_conn, :create), ctx.payload)
      assert %{"result" => "ok"} = json_response(conn, :created)
      created_task = get_last_task()

      # The driver gets the list of the nearest tasks by submitting current location [lat, long]
      conn = get(ctx.driver_conn, Routes.api_task_path(ctx.manager_conn, :index, %{"lat" => "55.753", "lng" => "37.622"}))
      assert %{"result" => "ok", "tasks" => tasks} = json_response(conn, :ok)
      [%{"id" => created_task_id} | _] = tasks
      assert created_task_id == created_task.id

      # Driver picks one task from the list (the task becomes assigned)
      conn = put(ctx.driver_conn, Routes.api_task_path(ctx.manager_conn, :pick, created_task_id), %{})
      assert %{"result" => "ok"} = json_response(conn, :ok)

      # Driver finishes the task (becomes done)
      conn = put(ctx.driver_conn, Routes.api_task_path(ctx.manager_conn, :pick, created_task_id), %{})
      assert %{"result" => "ok"} = json_response(conn, :ok)
    end
  end
end
