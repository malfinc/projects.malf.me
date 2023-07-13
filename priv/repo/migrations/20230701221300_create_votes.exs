defmodule Core.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :tier, :citext, null: false
      add :primary_nomination_id, references(:nominations, on_delete: :nothing), null: false
      add :secondary_nomination_id, references(:nominations, on_delete: :nothing), null: false
      add :tertiary_nomination_id, references(:nominations, on_delete: :nothing), null: false
      add :account_id, references(:accounts, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:votes, [:tier])
    create unique_index(:votes, [:account_id, :primary_nomination_id])
    create unique_index(:votes, [:account_id, :secondary_nomination_id])
    create unique_index(:votes, [:account_id, :tertiary_nomination_id])
    create index(:votes, [:primary_nomination_id])
    create index(:votes, [:secondary_nomination_id])
    create index(:votes, [:tertiary_nomination_id])
  end
end
