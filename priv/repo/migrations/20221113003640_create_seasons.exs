defmodule Core.Repo.Migrations.CreateSeasons do
  use Ecto.Migration

  def change do
    create(table(:seasons)) do
      add :position, :float, null: false
      timestamps()
    end

    create(unique_index(:seasons, [:position]))
  end
end
