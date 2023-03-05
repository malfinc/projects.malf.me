defmodule Core.Repo.Migrations.RefactorPositionProperties do
  use Ecto.Migration

  import Ecto.Query

  def change do
    alter(table(:champions)) do
      remove :position
      add :position, :integer, null: false, default: 0
    end

    flush()

    Core.Gameplay.list_champions(fn schema ->
      from(schema, order_by: {:asc, :inserted_at})
    end)
    |> Enum.with_index()
    |> Enum.each(fn {champion, index} ->
      Core.Gameplay.update_champion(champion, %{position: index + 1})
    end)

    flush()

    create(unique_index(:champions, [:position]))

    alter(table(:seasons)) do
      remove :position
      add :position, :integer, null: false, default: 0
    end

    flush()

    Core.Gameplay.list_seasons(fn schema ->
      from(schema, order_by: {:asc, :inserted_at})
    end)
    |> Enum.with_index()
    |> Enum.each(fn {season, index} ->
      Core.Gameplay.update_season(season, %{position: index + 1})
    end)

    flush()

    create(unique_index(:seasons, [:position]))

    alter(table(:weeklies)) do
      add :position, :integer, null: false, default: 0
    end

    flush()

    Core.Gameplay.list_weeklies(fn schema ->
      from(schema, order_by: {:asc, :inserted_at})
    end)
    |> Enum.with_index()
    |> Enum.group_by(&Map.get(&1, :season_id))
    |> Enum.each(fn {season_id, weeklies} ->
      Enum.each(weeklies, fn {weekly, index} ->
        Core.Gameplay.update_weekly(weekly, %{position: index + 1})
      end)
    end)

    flush()

    create(unique_index(:weeklies, [:position, :season_id]))

    alter(table(:cards)) do
      add :position, :integer, null: false, default: 0
    end

    flush()

    Core.Gameplay.list_cards(fn schema ->
      from(schema, order_by: {:asc, :inserted_at})
    end)
    |> Enum.with_index()
    |> Enum.group_by(&Map.get(&1, :season_id))
    |> Enum.each(fn {season_id, cards} ->
      Enum.each(cards, fn {card, index} ->
        Core.Gameplay.update_card(card, %{position: index + 1})
      end)
    end)

    flush()

    create(unique_index(:cards, [:position, :season_id]))

    alter(table(:packs)) do
      add :position, :integer, null: false, default: 0
    end

    flush()

    Core.Gameplay.list_packs(fn schema ->
      from(schema, order_by: {:asc, :inserted_at})
    end)
    |> Enum.with_index()
    |> Enum.group_by(&Map.get(&1, :season_id))
    |> Enum.each(fn {season_id, packs} ->
      Enum.each(packs, fn {pack, index} ->
        Core.Gameplay.update_pack(pack, %{position: index + 1})
      end)
    end)

    flush()

    create(unique_index(:packs, [:position, :season_id]))
  end
end
