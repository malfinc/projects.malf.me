defmodule Core.Repo.Migrations.CreateCoinTransactions do
  use Ecto.Migration

  def change do
    create(table(:coin_transactions)) do
      add :value, :integer, null: false
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      timestamps()
    end

    create(index(:coin_transactions, [:account_id]))
  end
end
