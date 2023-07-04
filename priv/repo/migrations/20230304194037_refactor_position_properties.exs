defmodule Core.Repo.Migrations.RefactorPositionProperties do
  use Ecto.Migration

  def change do
    alter(table(:champions)) do
      remove :position
      add :position, :integer, null: false, default: 0
    end

    create(unique_index(:champions, [:position]))

    alter(table(:seasons)) do
      remove :position
      add :position, :integer, null: false, default: 0
    end

    create(unique_index(:seasons, [:position]))

    alter(table(:weeklies)) do
      add :position, :integer, null: false, default: 0
    end

    create(unique_index(:weeklies, [:position, :season_id]))

    alter(table(:cards)) do
      add :position, :integer, null: false, default: 0
    end

    create(unique_index(:cards, [:position, :season_id]))

    alter(table(:packs)) do
      add :position, :integer, null: false, default: 0
    end

    create(unique_index(:packs, [:position, :season_id]))
  end
end
