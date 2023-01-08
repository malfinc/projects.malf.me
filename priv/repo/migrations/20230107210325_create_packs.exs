defmodule Core.Repo.Migrations.CreatePacks do
  use Ecto.Migration

  def change do
    create(table(:packs)) do
      add :opened, :boolean, null: false, default: false
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
      timestamps()
    end
    create(index(:packs, [:season_id]))

    create(table(:pack_slots)) do
      add :flipped, :boolean, null: false, default: false
      add :pack_id, references(:packs, on_delete: :delete_all), null: false
      add :champion_id, references(:champions, on_delete: :delete_all), null: false
      timestamps()
    end

    create(unique_index(:pack_slots, [:pack_id, :champion_id]))
    create(index(:pack_slots, [:champion_id]))
  end
end
