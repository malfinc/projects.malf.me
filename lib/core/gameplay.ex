defmodule Core.Gameplay do
  @moduledoc false
  import Core.Context
  require Logger

  resource(:plants, :plant, Core.Gameplay.Plant)
  resource(:seasons, :season, Core.Gameplay.Season)
  resource(:packs, :pack, Core.Gameplay.Pack)
  resource(:pack_slots, :pack_slot, Core.Gameplay.PackSlot)
  resource(:champions, :champion, Core.Gameplay.Champion)
  resource(:rarities, :rarity, Core.Gameplay.Rarity)
  resource(:coin_transactions, :coin_transaction, Core.Gameplay.CoinTransaction)
  resource(:challenges, :challenge, Core.Gameplay.Challenge)
  resource(:matches, :match, Core.Gameplay.Match)
  resource(:cards, :card, Core.Gameplay.Card)
  resource(:weeklies, :weekly, Core.Gameplay.Weekly)

  @spec odds(Core.Gameplay.Season.t(), Core.Gameplay.Rarity.t(), pos_integer()) :: float
  def odds(season, rarity, packs)
      when is_struct(rarity, Core.Gameplay.Rarity) and is_integer(packs) do
    total_packs = count_cards() / 6
    cards = Core.Repo.preload(list_cards(), [:rarity])
    distribution = card_rarity_distribution(season, cards)
    chance_to_pick = Map.get(distribution, rarity.name) / total_packs
    chance_to_not_pick = 1.0 - chance_to_pick

    1.0 - Enum.reduce(1..(packs + 1), fn _, sum -> chance_to_not_pick * sum end)
  end

  @spec card_rarity_distribution(Core.Gameplay.Season.t()) :: map
  def card_rarity_distribution(season), do: card_rarity_distribution(season, list_cards())

  @spec card_rarity_distribution(Core.Gameplay.Season.t(), list(Core.Gameplay.Card.t())) :: map
  def card_rarity_distribution(season, cards) do
    cards
    |> Core.Repo.preload([:rarity])
    |> Enum.filter(fn %{season_id: season_id} -> season.id == season_id end)
    |> Enum.group_by(&Map.get(&1, :rarity))
    |> Map.new(fn {rarity, cards} -> {rarity.name, length(cards)} end)
  end

  @spec purchase_packs(Core.Gameplay.Season.t(), Core.Users.Account.t(), pos_integer) :: :ok
  def purchase_packs(season, account, count) do
    for _ <- 1..count do
      pack = Core.Repo.preload(Core.Gameplay.random_pack(where: [season_id: season.id]), [cards: [:rarity, :champion]])

      Core.Gameplay.update_pack!(pack, %{account: account})

      # Deduct coins
    end

    :ok
  end

  @spec open_packs(Core.Season.Gameplay.t(), pos_integer()) :: :ok
  def open_packs(season, count) do
    for number <- 1..count do
      pack = Core.Repo.preload(Core.Gameplay.random_pack(where: [season_id: season.id]), [cards: [:rarity, :champion]])

      for card <- pack.cards do
        Logger.info("Pulled #{card.champion.name} (#{card.rarity.name}) from pack #{number}")
      end
    end

    :ok
  end

  def current_season_id(), do: from(Core.Gameplay.Season, where: [active: true], limit: 1) |> Core.Repo.one() |> Map.get(:id)
end
