defmodule Core.Repo.Migrations.CreateHalls do
  use Ecto.Migration

  def change do
    create table(:halls) do
      add :state, :citext, null: false
      add :deadline_at, :utc_datetime, null: false
      add :category, :citext, null: false

      timestamps()
    end
    create index(:halls, [:state])
    create index(:halls, [:deadline_at])
    create index(:halls, [:category])
  end
end
