defmodule Core.Repo.Migrations.AddCardRatesToRarities do
  use Ecto.Migration

  def change do
    alter(table(:rarities)) do
      add :season_pick_rates, :integer, null: false, default: 0
      add :pack_pick_percentage, :float, null: false, default: 0.0
    end
  end
end
