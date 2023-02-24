defmodule Core.Job.StartSeasonJob do
  @moduledoc """
  After starting a season fill the season with capable champions and then put those champions into conferences and divisions.
  """
  use Oban.Worker

  @pack_size 6

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          :ok | {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    Core.Repo.transaction(fn ->
      Core.Gameplay.get_season(season_id)
      |> Core.Repo.preload([:plants])
      |> tap(&generate_champions/1)
      |> tap(&generate_weeklies/1)
    end)
  end

  defp generate_champions(nil), do: nil

  defp generate_champions(season) do
    words = File.read!(Application.app_dir(:core, "priv/data/words.txt")) |> String.split("\n")
    rarities = Core.Gameplay.list_rarities()
    for _ <- 1..64 do
      %{plant: plant(season), name: name(words)}
      |> Core.Gameplay.create_champion!()
      |> generate_cards(rarities, season)
      |> generate_packs(rarities, season)
    end
  end

  defp generate_weeklies(nil), do: {:snooze, 60}

  defp generate_weeklies(season) when is_struct(season, Core.Gameplay.Season) do
    for _ <- 1..12 do
      Core.Gameplay.create_weekly!(%{season: season})
    end
  end

  defp generate_cards(champion, rarities, season) when is_struct(champion, Core.Gameplay.Champion) and is_list(rarities) do
    for rarity <- rarities do
      generate_card(champion, rarity, season)
    end
  end

  defp generate_packs(cards, rarities, season) do
    cards_by_rarity = Enum.group_by(cards, &Map.get(&1, :rarity))
    rarity_with_chance_by_slot =
    for card_chunks <- Enum.chunk_every(cards, @pack_size) do
      pack = Core.Gameplay.create_pack(%{season: season})
      for {_, index} <- Enum.with_index(card_chunks) do
        Core.Gameplay.create_pack_slot!(%{
          pack: pack,
          card: Enum.random(cards_by_rarity[Utilities.List.random(rarity_with_chance_by_slot[index])])
        })
      end
    end
  end

  defp generate_card(champion, rarity, season) do
    for _ <- 1..rarity.season_pick_rates do
      Core.Gameplay.create_card!(%{
        champion: champion,
        season: season,
        rarity: rarity
      })
    end
  end

  defp plant(season) when is_struct(season, Core.Gameplay.Season) do
    season.plants |> Enum.random()
  end

  defp name(words) do
    Utilities.Enum.multiple_unique(2, 2, fn ->
      words |> Enum.random()
    end)
    |> Enum.join(" ")
    |> Utilities.String.titlecase()
  end
end
