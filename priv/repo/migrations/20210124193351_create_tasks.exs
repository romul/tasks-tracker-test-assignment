defmodule TasksTracker.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :caption, :string, null: false
      add :state, :string, null: false, default: "new"
      add :pickup_point, :geography, null: false
      add :delivery_point, :geography, null: false
      add :manager_id, references(:users)
      add :driver_id, references(:users)

      timestamps()
    end

    create index(:tasks, :driver_id)
    create index(:tasks, :manager_id)
  end
end
