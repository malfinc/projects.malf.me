defmodule Core.Repo.Migrations.CopyImageUriFromPlantsToChampions do
  use Ecto.Migration

  def change do
    for champion <- Core.Repo.preload(Core.Gameplay.list_champions(), :plant) do
      Core.Gameplay.update_champion!(champion, %{image_uri: champion.plant.image_uri})
      Core.Gameplay.update_plant!(champion.plant, %{image_uri: "n/a"})
    end
  end
end
