defmodule Core.Repo.Migrations.AddPatrionAccountIdToUpgrades do
  use Ecto.Migration

  def change do
    alter(table(:upgrades)) do
      add :patron_account_id, references(:accounts, on_delete: :delete_all), null: false
    end

    create(index(:upgrades, [:patron_account_id]))
  end
end
