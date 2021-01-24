defmodule TasksTrackerWeb.TaskView do
  use TasksTrackerWeb, :view

  def render("index.json", %{tasks: tasks}) do
    %{
      result: "ok",
      tasks: tasks
    }
  end
end
