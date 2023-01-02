defmodule Core.Repo.Migrations.AddPositionToChampions do
  use Ecto.Migration

  def change do
    Core.Repo.delete_all(Core.Gameplay.Champion)

    flush()

    alter(table(:champions)) do
      add :position, :bigserial, null: false
    end
  end
end
