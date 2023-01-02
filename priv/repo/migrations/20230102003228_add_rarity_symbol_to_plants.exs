defmodule Core.Repo.Migrations.AddRaritySymbolToPlants do
  use Ecto.Migration

  def change do
    alter(table(:plants)) do
      add :rarity_symbol, :text, null: false
    end
  end
end
