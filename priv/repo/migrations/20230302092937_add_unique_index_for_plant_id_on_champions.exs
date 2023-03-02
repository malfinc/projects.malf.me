defmodule Core.Repo.Migrations.AddUniqueIndexForPlantIdOnChampions do
  use Ecto.Migration

  def change do
    drop(index(:champions, [:plant_id]))
    create(unique_index(:champions, [:plant_id]))
  end
end
