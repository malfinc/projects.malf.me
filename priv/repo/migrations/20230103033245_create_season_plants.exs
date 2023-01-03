defmodule Core.Repo.Migrations.CreateSeasonPlants do
  use Ecto.Migration

  def change do
    create(table(:season_plants, primary_key: false)) do
      add :plant_id, references(:plants, on_delete: :delete_all), null: false
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
    end

    create(unique_index(:season_plants, [:plant_id, :season_id]))
    create(index(:season_plants, [:season_id]))
  end
end
