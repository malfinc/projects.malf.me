defmodule Core.Repo.Migrations.DropChallenges do
  use Ecto.Migration

  def change do
    drop(table(:challenges))
  end
end
