defmodule Core.Job.StartSeasonJob do
  @moduledoc """
  After starting a season fill the season with capable champions and then put those champions into conferences and divisions.
  """
  use Oban.Worker
  require Logger

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
        end, timeout: 60_000 * 10)
    end
  end

  def generate_champions(season) do
    words = File.read!(Application.app_dir(:core, "priv/data/words.txt")) |> String.trim() |> String.split("\n")

    for name <- names(words) do
      Core.Gameplay.create_champion!(%{plant: plant(season), name: name})
    end
  end

  def generate_weeklies(season) do
    for _ <- 1..@weekly_size do
      Core.Gameplay.create_weekly!(%{season: season})
    end
  end

  def generate_packs(season, rarities, cards) do
    rarity_with_chance_by_slot = rarities
    |> Enum.map(fn %{pack_pick_percentages: pack_pick_percentages} = rarity ->
      Enum.map(pack_pick_percentages, (&{rarity, &1}))
    end)
    |> Enum.zip()

    for card_chunks <- Enum.chunk_every(cards, @pack_size), reduce: cards do
      available_cards ->
        Logger.debug("Available cards for slots: #{length(available_cards)}")
        {_, picked_cards} = generate_pack(
          length(card_chunks) - 1,
          rarity_with_chance_by_slot,
          Enum.group_by(available_cards, &Map.get(&1, :rarity)),
          season
        )
        (available_cards -- picked_cards)
        |> tap(fn x -> Logger.debug("Available cards for slots: #{length(x)}") end)
    end
  end

  def generate_pack(maximum_number_of_slots, rarity_with_chance_by_slot, cards_by_rarity, season) do
    pack = Core.Gameplay.create_pack!(%{season: season})

    for slot <- 0..maximum_number_of_slots, reduce: {cards_by_rarity, []} do
      {available_cards_by_rarity, picked_cards} ->
        %{card: card} = pick_card_for_slot(slot, pack, rarity_with_chance_by_slot, available_cards_by_rarity)
        cards_for_picked_rarity = available_cards_by_rarity[card.rarity]
        remaining_without_picked_cards = List.delete(cards_for_picked_rarity, card)

        {
          Map.put(available_cards_by_rarity, card.rarity, remaining_without_picked_cards),
          [card | picked_cards]
        }
    end
  end

  def pick_card_for_slot(slot, pack, rarity_with_chance_by_slot, cards_by_rarity) do
    possible_rarities = rarity_with_chance_by_slot
    |> Enum.at(slot)
    |> Tuple.to_list()
    |> Enum.filter(fn {rarity, _percentage} -> length(Map.get(cards_by_rarity, rarity, [])) > 0 end)

    Logger.debug("Picking a random card from the remaining rarities (For slot #{slot + 1}):")

    possible_rarities
    |> Enum.each(fn {rarity, chance} ->
      Logger.debug("#{rarity.name} (#{chance}%, #{length(cards_by_rarity[rarity])})")
    end)

    card = Utilities.until(fn ->
      possible_rarities
      |> Utilities.List.random()
      |> tap(fn
        nil -> Logger.debug("No rarity?!")
        picked_rarity -> Logger.debug("Picked rarity: #{picked_rarity.name}")
      end)
      |> (&Map.get(cards_by_rarity, &1, [])).()
      |> Enum.random()
    end)

    Logger.debug("Picked #{card.champion.name} (#{card.rarity.name}, #{card.id}) on pack #{pack.id}")

    Core.Gameplay.create_pack_slot!(%{
      pack: pack,
      card: card
    })
  end

  def generate_cards(champions, rarities, season) do
    for rarity <- rarities, champion <- champions, reduce: [] do
      accumulated -> accumulated ++ generate_card(champion, rarity, season)
    end
  end

  def generate_card(champion, rarity, season) do
    for _ <- 1..rarity.season_pick_rate do
      Core.Gameplay.create_card!(%{
        champion: champion,
        season: season,
        rarity: rarity
      })
    end
  end

  def plant(season) when is_struct(season, Core.Gameplay.Season) do
    season.plants |> Enum.random()
  end

  def names(words) do
    Utilities.Enum.multiple_unique(@champion_pool_size, @champion_pool_size, fn ->
      "#{words |> Enum.random()} #{words |> Enum.random()}"
    end)
    |> Enum.map(&Utilities.String.titlecase/1)
  end
end
