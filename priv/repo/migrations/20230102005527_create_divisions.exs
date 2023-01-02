defmodule Core.Repo.Migrations.CreateDivisions do
  use Ecto.Migration

  def change do
    create(table(:divisions)) do
      add :name, :text, null: false
      add :slug, :citext, null: false
      timestamps()
    end

    create(unique_index(:divisions, [:name]))
    create(unique_index(:divisions, [:slug]))
  end
end
