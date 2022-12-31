defmodule Core.Repo.Migrations.CreateChampions do
  use Ecto.Migration

  def change do
    create(table(:champions)) do
      add :name, :text, null: false
      add :slug, :citext, null: false
      add :plant_id, references(:plants, on_delete: :delete_all), null: false
      timestamps()
    end

    create(unique_index(:champions, [:name]))
    create(unique_index(:champions, [:slug]))
    create(index(:champions, [:plant_id]))
  end
end
