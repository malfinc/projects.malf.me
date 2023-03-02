defmodule Core.Repo.Migrations.AddImageUriToChampions do
  use Ecto.Migration

  def change do
    alter(table(:champions)) do
      add :image_uri, :citext
    end
  end
end
