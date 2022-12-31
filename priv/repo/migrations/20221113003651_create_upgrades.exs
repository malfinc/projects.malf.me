defmodule Core.Repo.Migrations.CreateUpgrades do
  use Ecto.Migration

  def change do
    create(table(:upgrades)) do
      add :stage, :integer, null: false
      add :strength, :integer, null: false, default: 0
      add :speed, :integer, null: false, default: 0
      add :intelligence, :integer, null: false, default: 0
      add :endurance, :integer, null: false, default: 0
      add :luck, :integer, null: false, default: 0

      add :seasonal_statistic_id, references(:seasonal_statistics, on_delete: :delete_all),
        null: false

      timestamps()
    end

    create(index(:upgrades, [:stage]))
    create(index(:upgrades, [:strength]))
    create(index(:upgrades, [:speed]))
    create(index(:upgrades, [:intelligence]))
    create(index(:upgrades, [:endurance]))
    create(index(:upgrades, [:luck]))
    create(index(:upgrades, [:seasonal_statistic_id]))
  end
end
