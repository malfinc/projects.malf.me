defmodule Core.Repo.Migrations.ChangePositionFromIntegerToBigserialOnSeasons do
  use Ecto.Migration

  def change do
    Core.Repo.delete_all(Core.Gameplay.Season)

    flush()

    alter(table(:seasons)) do
      remove :position
    end

    alter(table(:seasons)) do
      add :position, :bigserial
    end
  end
end
