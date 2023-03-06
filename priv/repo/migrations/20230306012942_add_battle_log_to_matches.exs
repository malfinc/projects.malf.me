defmodule Core.Repo.Migrations.AddBattleLogToMatches do
  use Ecto.Migration

  def change do
    alter(table(:matches)) do
      add :rounds, {:array, :text}, null: false, default: []
    end
  end
end
