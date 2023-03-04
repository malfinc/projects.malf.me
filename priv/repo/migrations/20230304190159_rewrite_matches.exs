defmodule Core.Repo.Migrations.RewriteMatches do
  use Ecto.Migration

  def change do
    alter(table(:matches)) do
      remove :challenge_id
      add :season_id, references(:seasons, on_delete: :delete_all), null: false
      add :division_id, references(:divisions, on_delete: :delete_all), null: false
      add :weekly_id, references(:weeklies, on_delete: :delete_all), null: false
    end

    create(
      unique_index(:matches, [
        :season_id,
        :division_id,
        :weekly_id,
        :left_champion_id,
        :right_champion_id
      ])
    )

    create(index(:matches, [:season_id]))
    create(index(:matches, [:division_id]))
    create(index(:matches, [:weekly_id]))
  end
end
