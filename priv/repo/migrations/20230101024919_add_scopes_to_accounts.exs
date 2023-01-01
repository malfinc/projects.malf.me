defmodule Core.Repo.Migrations.AddScopesToAccounts do
  use Ecto.Migration

  def change do
    alter(table(:accounts)) do
      add :provider_scopes, {:array, :text}, null: false, default: []
    end
  end
end
