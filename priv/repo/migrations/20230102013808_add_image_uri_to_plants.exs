defmodule Core.Repo.Migrations.AddImageUriToPlants do
  use Ecto.Migration

  def change do
    alter(table(:plants)) do
      add :image_uri, :text, null: false
    end
  end
end
