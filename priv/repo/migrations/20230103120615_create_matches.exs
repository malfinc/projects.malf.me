defmodule Core.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create(table(:matches)) do
      add :left_champion_id, references(:champions, on_delete: :delete_all)
      add :right_champion_id, references(:champions, on_delete: :delete_all)
      add :challenge_id, references(:challenges, on_delete: :delete_all), null: false
      timestamps()
    end

    create(index(:matches, [:left_champion_id, :right_champion_id]))
    create(index(:matches, [:right_champion_id]))
    create(index(:matches, [:challenge_id]))
  end
end
