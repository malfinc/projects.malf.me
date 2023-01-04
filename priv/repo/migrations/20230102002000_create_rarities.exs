defmodule Core.Repo.Migrations.CreateRarities do
  use Ecto.Migration

  def change do
    create(table(:rarities)) do
      add :name, :text, null: false
      add :slug, :citext, null: false
      add :color, :text, null: false
      timestamps()
    end

    create(unique_index(:rarities, [:name]))
    create(unique_index(:rarities, [:slug]))
  end
end
