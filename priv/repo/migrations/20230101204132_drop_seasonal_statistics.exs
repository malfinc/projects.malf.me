defmodule Core.Repo.Migrations.DropSeasonalStatistics do
  use Ecto.Migration

  def change do
    drop(table(:seasonal_statistics))
  end
end
