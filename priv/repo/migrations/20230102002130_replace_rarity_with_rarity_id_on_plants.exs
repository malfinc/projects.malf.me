defmodule Core.Repo.Migrations.ReplaceRarityWithRarityIdOnPlants do
  use Ecto.Migration

  def change do
    alter(table(:plants)) do
      remove :rarity
      add :rarity_id, references(:rarities, on_delete: :delete_all)
    end
    create(index(:plants, [:rarity_id]))
  end
end
