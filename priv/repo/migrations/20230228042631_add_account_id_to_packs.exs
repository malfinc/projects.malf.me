defmodule Core.Repo.Migrations.AddAccountIdToPacks do
  use Ecto.Migration

  def change do
    alter(table(:packs)) do
      add :account_id, references(:accounts, on_delete: :nilify_all)
    end

    create(index(:packs, [:account_id]))
  end
end
