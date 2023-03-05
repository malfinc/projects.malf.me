defmodule Core.Repo.Migrations.DropChallengeChampions do
  use Ecto.Migration

  def change do
    drop(table(:challenge_champions))
  end
end
