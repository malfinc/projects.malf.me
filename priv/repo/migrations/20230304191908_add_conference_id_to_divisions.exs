defmodule Core.Repo.Migrations.AddConferenceIdToDivisions do
  use Ecto.Migration

  def change do
    alter(table(:divisions)) do
      add :conference_id, references(:conferences, on_delete: :delete_all), null: false
    end
  end
end
