defmodule Core.Repo.Migrations.RecreatePackSlots do
  use Ecto.Migration

  def change do
    drop(table(:pack_slots))

    create(table(:pack_slots)) do
      add :pack_id, references(:packs, on_delete: :delete_all), null: false
      add :card_id, references(:cards, on_delete: :delete_all), null: false
      timestamps()
    end

    create(index(:pack_slots, [:pack_id]))
    create(unique_index(:pack_slots, [:card_id]))
  end
end
