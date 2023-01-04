defmodule Core.Repo.Migrations.CreateChallenges do
  use Ecto.Migration

  def change do
    create(table(:challenges)) do
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
      timestamps()
    end

    create(index(:challenges, [:season_id]))
  end
end
