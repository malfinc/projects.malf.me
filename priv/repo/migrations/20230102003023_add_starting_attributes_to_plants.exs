defmodule Core.Repo.Migrations.AddStartingAttributesToPlants do
  use Ecto.Migration

  def change do
    alter(table(:plants)) do
      add :starting_attributes, :map, null: false
    end
  end
end
