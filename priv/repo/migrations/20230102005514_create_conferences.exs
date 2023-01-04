defmodule Core.Repo.Migrations.CreateConferences do
  use Ecto.Migration

  def change do
    create(table(:conferences)) do
      add :name, :text, null: false
      add :slug, :citext, null: false
      timestamps()
    end

    create(unique_index(:conferences, [:name]))
    create(unique_index(:conferences, [:slug]))
  end
end
