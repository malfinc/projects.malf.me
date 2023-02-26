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

  def rarity_distribution(season) do
    list_cards()
    |> Core.Repo.preload([:rarity])
    |> Enum.filter(fn %{season_id: season_id} -> season.id == season_id end)
    |> Enum.group_by(&Map.get(&1, :rarity))
    |> Map.new(fn {rarity, cards} -> {rarity.name, length(cards)} end)
  end

  def distribution(season) do
    list_packs()
    |> Core.Repo.preload([cards: [:rarity]])
    |> Enum.filter(fn %{season_id: season_id} -> season.id == season_id end)
    |> Enum.map(fn pack ->
      pack.cards
      |> Enum.group_by(&Map.get(&1, :rarity))
      |> Map.new(fn {rarity, cards} -> {rarity.name, length(cards)} end)
    end)
    |> List.flatten()
    |> Enum.reduce(%{}, fn dist, acc -> Map.merge(acc, dist, fn _, a, b -> a + b end) end)
    # |> Enum.group_by(fn x -> x end)
    # |> Map.new(fn {rarity, packs} -> {rarity, length(packs)} end)
    # |> Enum.reduce(rarity_mapping, fn pack, mapping ->
    #   pack.cards
    #   |> Enum.group_by(&Map.get(&1, :rarity))
    #   |> Enum.map(fn
    #     {rarity, []} -> {rarity.name, mapping[rarity.name]}
    #     {rarity, cards} -> {rarity.name, [length(cards) | mapping[rarity.name]]}
    #   end)
    #   |> Map.new()
    # end)
  end
end
