defmodule Core.Gameplay do
  @moduledoc false
  require Logger

  use EctoInterface, [Core.Gameplay.Plant, :plants, :plant]
  use EctoInterface, [Core.Gameplay.Season, :seasons, :season]
  use EctoInterface, [Core.Gameplay.Pack, :packs, :pack]
  use EctoInterface, [Core.Gameplay.PackSlot, :pack_slots, :pack_slot]
  use EctoInterface, [Core.Gameplay.Champion, :champions, :champion]
  use EctoInterface, [Core.Gameplay.Rarity, :rarities, :rarity]
  use EctoInterface, [Core.Gameplay.CoinTransaction, :coin_transactions, :coin_transaction]
  use EctoInterface, [Core.Gameplay.Match, :matches, :match]
  use EctoInterface, [Core.Gameplay.Card, :cards, :card]
  use EctoInterface, [Core.Gameplay.Weekly, :weeklies, :weekly]
  use EctoInterface, [Core.Gameplay.Division, :divisions, :division]
  use EctoInterface, [Core.Gameplay.Conference, :conferences, :conference]

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

  @spec purchase_packs(Core.Gameplay.Season.t(), Core.Users.Account.t(), pos_integer) ::
          list(atom())
  def purchase_packs(season, account, count) do
    for _ <- 1..count do
      Core.Repo.transaction(fn ->
        Core.Gameplay.random_pack(fn cards -> from(cards, where: [season_id: ^season.id]) end)
        |> Core.Repo.preload(cards: [:rarity, :champion])
        |> case do
          nil ->
            {:error, "no packs available"}

          pack ->
            if Core.Gameplay.can_spend?(account, 1.0) do
              Core.Gameplay.spend_coins(account, 1.0, "purchasing a pack of cards")
              |> case do
                {:ok, _} ->
                  Core.Gameplay.update_pack(pack, %{account: account})
              end
            else
              {:error, "not enough funds"}
            end
        end
      end)
      |> case do
        {:ok, transaction} -> transaction
        {:error, _changeset} = result -> result
      end
    end
  end

  @spec can_spend?(Core.Users.Account.t(), float()) :: boolean()
  def can_spend?(account, value) do
    account.coin_transactions
    |> Utilities.List.pluck(:value)
    |> Enum.sum()
    |> Kernel.>=(value)
  end

  @spec spend_coins(Core.Users.Account.t(), float(), String.t()) ::
          {:error, Ecto.Changeset.t()} | {:ok, Core.Gameplay.CoinTransaction.t()}
  def spend_coins(account, value, reason) do
    Core.Gameplay.create_coin_transaction(%{
      reason: reason,
      account: account,
      value: -value
    })
  end

  @spec open_pack(Core.Gameplay.Pack.t(), Core.Users.Account.t()) :: {:ok, any()}
  def open_pack(pack, account) do
    Core.Repo.transaction(fn ->
      pack
      |> Core.Gameplay.update_pack(%{opened: true})
      |> case do
        {:ok, %{cards: cards}} ->
          for card <- cards do
            Core.Gameplay.update_card(card, %{account: account})
          end
      end
    end)
  end

  @spec current_season() :: Core.Gameplay.Season.t()
  def current_season(),
    do: from(Core.Gameplay.Season, where: [active: true], limit: 1) |> Core.Repo.one()

  @spec current_season_id() :: String.t()
  def current_season_id(), do: current_season() |> Map.get(:id)

  @doc """
  Takes a match and generates each round of action between two combatants, ending when one has no HP left.

  Each round is a tuple of the "round actor" and a log of the action (`{Core.Gameplay.Champion.t(), String.t()}`).
  """
  @spec fight(Core.Gameplay.Match.t()) :: list(tuple())
  def fight(%Core.Gameplay.Match{left_champion: left_champion, right_champion: right_champion}) do
    Stream.unfold(Enum.map([left_champion, right_champion], &as_combatants/1), &clash/1)
    |> Enum.to_list()
  end

  defp as_combatants(champion) do
    Map.put(champion, :hp, 10)
  end

  defp clash([%{hp: hp}, _]) when hp <= 0, do: nil

  defp clash([_, %{hp: hp}]) when hp <= 0, do: nil

  defp clash([left_champion, right_champion]) do
    damage = Enum.random(1..3)

    Enum.random([:left_champion, :right_champion])
    |> case do
      :left_champion ->
        {
          {
            left_champion,
            "#{left_champion.name} did #{damage}HP in damage to #{right_champion.name}"
          },
          [
            Map.put(left_champion, :hp, left_champion.hp - damage),
            right_champion
          ]
        }

      :right_champion ->
        {
          {
            right_champion,
            "#{right_champion.name} did #{damage}HP in damage to #{right_champion.name}"
          },
          [
            left_champion,
            Map.put(right_champion, :hp, right_champion.hp - damage)
          ]
        }
    end
  end
end
