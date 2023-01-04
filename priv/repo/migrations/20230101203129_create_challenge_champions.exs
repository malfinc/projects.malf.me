defmodule Core.Repo.Migrations.CreateChallengeChampions do
  use Ecto.Migration

  def change do
    create(table(:challenge_champions)) do
      add :champion_id, references(:champions, on_delete: :delete_all), null: false
      add :challenge_id, references(:challenges, on_delete: :delete_all), null: false
    end

    create(unique_index(:challenge_champions, [:champion_id, :challenge_id]))
    create(index(:challenge_champions, [:challenge_id]))
  end
end
