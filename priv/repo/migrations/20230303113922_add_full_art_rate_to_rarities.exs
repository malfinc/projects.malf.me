defmodule Core.Repo.Migrations.AddFullArtRateToRarities do
  use Ecto.Migration

  def change do
    alter(table(:rarities)) do
      add :full_art_rate, :float, null: false, default: 0.0
    end
  end
end
