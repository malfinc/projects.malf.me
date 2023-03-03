defmodule Core.Job.FillPackSlotsJob do
  @moduledoc """
  Fills all the empty packs in a season.
  """
  use Oban.Worker
  require Logger

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    season_id
    |> Core.Gameplay.get_season()
    |> Core.Repo.preload(cards: [:rarity, :champion], packs: [])
    |> case do
      nil ->
        {:snooze, 15}

      season ->
        rarities = Core.Gameplay.list_rarities()
        packs = season.packs
        cards = season.cards

        Core.Repo.transaction(
          fn ->
            rarities
            |> Enum.map(fn %{pack_slot_caps: pack_slot_caps} = rarity ->
              Enum.map(pack_slot_caps, &{rarity, &1})
            end)
            |> Enum.zip()
            |> Enum.map(&Tuple.to_list/1)
            |> Enum.with_index()
            |> Enum.reduce({cards, []}, fn {rarity_and_pack_slot_caps, slot},
                                           {unpacked_cards, slots} ->
              Logger.debug("Slot #{slot}, unpacked #{length(unpacked_cards)}")

              {available_cards, partial_pack_slots} =
                Enum.reduce(rarity_and_pack_slot_caps, {unpacked_cards, []}, fn {rarity,
                                                                                 pack_slot_cap},
                                                                                {available_cards,
                                                                                 partial_pack_slots} ->
                  {matching_cards, unmatched_cards} =
                    Enum.split_with(
                      available_cards,
                      fn %{rarity_id: rarity_id} -> rarity_id == rarity.id end
                    )

                  {allocated_cards, remaining_cards} = Enum.split(matching_cards, pack_slot_cap)

                  Logger.debug(
                    "#{rarity.name} #{pack_slot_cap}, available #{length(available_cards)}, partial #{length(partial_pack_slots)}, matching #{length(matching_cards)}, aonmatching #{length(unmatched_cards)}, allocated #{length(allocated_cards)}, remaining #{length(remaining_cards)}"
                  )

                  {
                    Enum.concat(remaining_cards, unmatched_cards),
                    Enum.concat(
                      partial_pack_slots,
                      Enum.map(allocated_cards, fn card -> %{card: card} end)
                    )
                  }
                end)

              {
                available_cards,
                Utilities.List.append(slots, partial_pack_slots)
              }
            end)
            |> then(fn {_, partial_pack_slot_by_slots} -> partial_pack_slot_by_slots end)
            |> Enum.each(fn partial_pack_slots ->
              partial_pack_slots
              |> Enum.zip(packs)
              |> Enum.each(fn {partial_pack_slot, pack} ->
                Core.Gameplay.create_pack_slot!(Map.merge(partial_pack_slot, %{pack: pack}))
              end)
            end)
          end,
          timeout: 30_000
        )
    end
  end
end
