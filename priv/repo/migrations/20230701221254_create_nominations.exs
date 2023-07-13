defmodule Core.Repo.Migrations.CreateNominations do
  use Ecto.Migration

  def change do
    create table(:nominations) do
      add :name, :text, null: false
      add :box_art_url, :text, null: false
      add :state, :citext, null: false
      add :external_game_id, :text, null: false
      add :hall_id, references(:halls, on_delete: :nothing), null: false
      add :account_id, references(:accounts, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:nominations, [:state])
    create unique_index(:nominations, [:external_game_id, :hall_id])
    create unique_index(:nominations, [:hall_id, :account_id])
    create index(:nominations, [:account_id])
  end
end
