defmodule Core.Repo.Migrations.AddCardRatesToRarities do
  use Ecto.Migration

  def change do
    alter(table(:rarities)) do
      add :season_pick_rate, :integer, null: false, default: 0
      add :pack_pick_percentages, {:array, :float}, null: false, default: []
    end
  end
end
