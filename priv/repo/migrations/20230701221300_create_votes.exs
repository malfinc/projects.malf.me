defmodule Core.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :tier, :citext, null: false
      add :preference, :citext, null: false
      add :nomination_id, references(:nominations, on_delete: :nothing), null: false
      add :account_id, references(:accounts, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:votes, [:tier])
    create index(:votes, [:preference])
    create unique_index(:votes, [:account_id, :nomination_id])
    create index(:votes, [:nomination_id])
  end
end
