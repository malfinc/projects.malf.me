defmodule Core.Repo.Migrations.CreateWeeklies do
  use Ecto.Migration

  def change do
    create(table(:weeklies)) do
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
      timestamps()
    end

    create(index(:weeklies, [:season_id]))
  end
end
