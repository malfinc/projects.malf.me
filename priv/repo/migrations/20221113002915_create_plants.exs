defmodule Core.Repo.Migrations.CreatePlants do
  use Ecto.Migration

  def change do
    create(table(:plants)) do
      add :name, :text, null: false
      add :slug, :citext, null: false
      add :rarity, :citext, null: false
      timestamps()
    end

    create(unique_index(:plants, [:name]))
    create(unique_index(:plants, [:slug]))
    create(index(:plants, [:rarity]))
  end
end
