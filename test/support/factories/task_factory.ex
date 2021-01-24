defmodule TasksTracker.TaskFactory do
  defmacro __using__(_opts) do
    quote do
      alias TasksTracker.{Task, Repo}

      def task_factory do
        struct(Task, task_params())
      end

      def task_params(params \\ %{}) do
        tver = %Geo.Point{coordinates: {35.9119, 56.85961}, srid: 4326}
        msk = %Geo.Point{coordinates: {37.62039, 55.75396}, srid: 4326}

        %{
          caption: "Msk->Tver",
          pickup_point: msk,
          delivery_point: tver
        }
        |> Map.merge(params)
      end

      def get_tasks_count do
        Repo.aggregate(Task, :count, :id)
      end
    end
  end
end
