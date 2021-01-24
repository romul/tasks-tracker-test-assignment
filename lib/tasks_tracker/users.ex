defmodule TasksTracker.Users do
  alias TasksTracker.{Repo, User}

  def create_manager(attrs \\ %{}) do
    %User{}
    |> User.changeset_to_create("manager", attrs)
    |> Repo.insert()
  end

  def create_driver(attrs \\ %{}) do
    %User{}
    |> User.changeset_to_create("driver", attrs)
    |> Repo.insert()
  end

  def get_user_by(token: token) do
    User |> Repo.get_by(token: token)
  end
end
