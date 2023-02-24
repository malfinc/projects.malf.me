defmodule Core.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create(table(:cards)) do
      add :rarity_id, references(:rarities, on_delete: :delete_all), null: false
      add :champion_id, references(:champions, on_delete: :delete_all), null: false
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
      timestamps()
    end

    create(index(:cards, [:champion_id]))
    create(index(:cards, [:season_id]))
    create(index(:cards, [:rarity_id]))
  end
end
