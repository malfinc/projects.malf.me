defmodule Core.Repo.Migrations.AddFullArtToCards do
  use Ecto.Migration

  def change do
    alter(table(:cards)) do
      add :full_art, :boolean, null: false, default: false
    end
  end
end
