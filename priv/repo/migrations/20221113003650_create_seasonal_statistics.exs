defmodule Core.Repo.Migrations.CreateSeasonalStatistics do
  use Ecto.Migration

  def change do
    create(table(:seasonal_statistics)) do
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
      add :champion_id, references(:champions, on_delete: :delete_all), null: false
      add :wins, :integer, null: false, default: 0
      add :losses, :integer, null: false, default: 0
      timestamps()
    end

    create(unique_index(:seasonal_statistics, [:season_id, :champion_id]))
    create(index(:seasonal_statistics, [:champion_id]))
  end
end
