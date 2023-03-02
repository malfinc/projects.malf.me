defmodule Core.Repo.Migrations.AddAccountIdToCards do
  use Ecto.Migration

  def change do
    alter(table(:cards)) do
      add :account_id, references(:accounts, on_delete: :nilify_all)
    end

    create(index(:cards, [:account_id]))
  end
end
