defmodule Core.Job.StartSeasonJob do
  @moduledoc """
  After starting a season fill the season with capable champions and then put those champions into conferences and divisions.
  """
  use Oban.Worker

  @pack_size 6
  @champion_pool_size 64
  @weekly_size 12

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          :ok | {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    rarities = Core.Gameplay.list_rarities()
    season_id
    |> Core.Gameplay.get_season()
    |> Core.Repo.preload([:plants])
    |> case do
      nil -> {:snooze, 15}
      season ->
        Core.Repo.transaction(fn ->
          generate_weeklies(season)
          champions = generate_champions(season)
          cards = generate_cards(champions, rarities, season)
          generate_packs(season, rarities, cards)
        end, timeout: 240_000)
    end
  end

  defp generate_champions(season) do
    words = File.read!(Application.app_dir(:core, "priv/data/words.txt")) |> String.trim() |> String.split("\n")

    for name <- names(words) do
      Core.Gameplay.create_champion!(%{plant: plant(season), name: name})
    end
  end

  defp generate_weeklies(season) do
    for _ <- 1..@weekly_size do
      Core.Gameplay.create_weekly!(%{season: season})
    end
  end

  defp generate_packs(season, rarities, cards) do
    cards_by_rarity = Enum.group_by(cards, &Map.get(&1, :rarity))
    rarity_with_chance_by_slot = rarities
    |> Enum.map(fn %{pack_pick_percentages: pack_pick_percentages} = rarity ->
      Enum.map(pack_pick_percentages, (&{rarity, &1}))
    end)
    |> Enum.zip()

    for card_chunks <- Enum.chunk_every(cards, @pack_size) do
      generate_pack(card_chunks, rarity_with_chance_by_slot, cards_by_rarity, season)
    end
  end

  defp generate_pack(card_chunks, rarity_with_chance_by_slot, cards_by_rarity, season) do
    pack = Core.Gameplay.create_pack!(%{season: season})

    for slot <- 0..(length(card_chunks) - 1), reduce: cards_by_rarity do
      available_cards_by_rarity ->
        pack_slot = pick_card_for_slot(slot, pack, rarity_with_chance_by_slot, available_cards_by_rarity)
        Map.put(available_cards_by_rarity, pack_slot.card.rarity, List.delete(available_cards_by_rarity[pack_slot.card.rarity], pack_slot.card))
    end
  end

  defp pick_card_for_slot(slot, pack, rarity_with_chance_by_slot, cards_by_rarity) do
    possible_rarities = rarity_with_chance_by_slot
    |> Enum.at(slot)
    |> Tuple.to_list()

    card = Utilities.until(fn ->
      possible_rarities
      |> Utilities.List.random()
      |> (&Map.get(cards_by_rarity, &1)).()
      |> Enum.random()
    end)

    Core.Gameplay.create_pack_slot!(%{
      pack: pack,
      card: card
    })
  end

  defp generate_cards(champions, rarities, season) do
    for champion <- champions, rarity <- rarities, reduce: [] do
      accumulated -> accumulated ++ generate_card(champion, rarity, season)
    end
  end

  defp generate_card(champion, rarity, season) do
    for _ <- 1..rarity.season_pick_rate do
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

  defp names(words) do
    Utilities.Enum.multiple_unique(@champion_pool_size, @champion_pool_size, fn ->
      "#{words |> Enum.random()} #{words |> Enum.random()}"
    end)
    |> Enum.map(&Utilities.String.titlecase/1)
  end
end
