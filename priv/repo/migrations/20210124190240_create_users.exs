defmodule TasksTracker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :full_name, :string, null: false
      add :phone, :string, null: false
      add :role, :string, null: false
      add :token, :string, null: false

      timestamps()
    end

    create index(:users, :token)
    create index(:users, :phone)
  end
end
