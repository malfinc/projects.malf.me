defmodule Core.Repo.Migrations.AddActiveToSeasons do
  use Ecto.Migration

  def change do
    alter(table(:seasons)) do
      add :active, :boolean, default: false, null: false
    end

    create(index(:seasons, [:active]))
  end
end
