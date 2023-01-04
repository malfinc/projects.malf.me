defmodule Core.Repo.Migrations.AddSpeciesNameToPlants do
  use Ecto.Migration

  def change do
    alter(table(:plants)) do
      add :species, :text, null: false
    end
  end
end
