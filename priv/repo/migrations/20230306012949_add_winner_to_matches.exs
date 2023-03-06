defmodule Core.Repo.Migrations.AddWinnerToMatches do
  use Ecto.Migration

  def change do
    alter(table(:matches)) do
      add :winning_champion_id, references(:champions, on_delete: :delete_all)
    end

    create(index(:matches, [:winning_champion_id]))
  end
end
