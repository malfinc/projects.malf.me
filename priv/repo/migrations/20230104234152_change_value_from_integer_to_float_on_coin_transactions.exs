defmodule Core.Repo.Migrations.ChangeValueFromIntegerToFloatOnCoinTransactions do
  use Ecto.Migration

  def change do
    alter(table(:coin_transactions)) do
      modify :value, :float
    end
  end
end
