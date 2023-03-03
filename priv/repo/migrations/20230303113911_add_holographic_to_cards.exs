defmodule Core.Repo.Migrations.AddHolographicToCards do
  use Ecto.Migration

  def change do
    alter(table(:cards)) do
      add :holographic, :boolean, null: false, default: false
    end
  end
end
