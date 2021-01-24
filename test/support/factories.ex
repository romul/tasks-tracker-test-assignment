defmodule TasksTracker.Factories do
  use ExUnit.CaseTemplate
  use ExMachina.Ecto, repo: TasksTracker.Repo
  use TasksTracker.TaskFactory
  use TasksTracker.UserFactory
end
