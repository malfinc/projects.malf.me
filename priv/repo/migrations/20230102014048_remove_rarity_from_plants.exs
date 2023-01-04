defmodule Core.Repo.Migrations.RemoveRarityFromPlants do
  use Ecto.Migration

  def change do
    alter(table(:plants)) do
      remove :rarity_id
    end
  end
end
