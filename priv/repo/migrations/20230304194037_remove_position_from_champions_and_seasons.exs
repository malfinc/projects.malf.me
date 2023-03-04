defmodule Core.Repo.Migrations.RemovePositionFromChampionsAndSeasons do
  use Ecto.Migration

  import Ecto.Query

  def change do
    alter(table(:champions)) do
      remove :position
    end

    alter(table(:seasons)) do
      remove :position
    end
  end
end
