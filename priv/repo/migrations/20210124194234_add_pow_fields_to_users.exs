defmodule TasksTracker.Repo.Migrations.AddPowFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :string
      add :password_hash, :string
    end
  end
end
