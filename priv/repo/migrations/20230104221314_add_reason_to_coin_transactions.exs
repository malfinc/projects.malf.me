defmodule Core.Repo.Migrations.AddReasonToCoinTransactions do
  use Ecto.Migration

  def change do
    alter(table(:coin_transactions)) do
      add :reason, :text, null: false, default: "unknown"
    end
  end
end
