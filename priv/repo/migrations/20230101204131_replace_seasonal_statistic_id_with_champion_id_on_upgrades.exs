defmodule Core.Repo.Migrations.ReplaceSeasonalStatisticIdWithChampionIdOnUpgrades do
  use Ecto.Migration

  def change do
    alter(table(:upgrades)) do
      remove :seasonal_statistic_id
      add :champion_id, references(:champions, on_delete: :delete_all), null: false
    end
    create(index(:upgrades, [:champion_id]))
  end
end
