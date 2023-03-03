defmodule Core.Repo.Migrations.AddHolographicRateToRarities do
  use Ecto.Migration

  def change do
    alter(table(:rarities)) do
      add :holographic_rate, :float, null: false, default: 0.0
    end
  end
end
