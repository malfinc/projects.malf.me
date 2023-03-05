defmodule Core.Job.GenerateCardsJob do
  @moduledoc """
  Generates all the cards for the season, based on the champions and rarity rates.
  """
  use Oban.Worker

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    season_id
    |> Core.Gameplay.get_season()
    |> case do
      nil ->
        {:snooze, 15}

      season ->
        rarities = Core.Gameplay.list_rarities()
        # I believe there needs to be some connection between season and champion?
        champions = Core.Gameplay.list_champions()

        Core.Repo.transaction(
          fn ->
            champions
            |> Enum.map(fn champion -> {champion, rarities} end)
            |> Enum.flat_map(fn {champion, rarities} ->
              Enum.map(rarities, fn rarity -> {champion, rarity, rarity.season_pick_rate} end)
            end)
            |> Enum.flat_map(fn {champion, rarity, season_pick_rate} ->
              Enum.map(1..season_pick_rate, fn _ -> {champion, rarity} end)
            end)
            |> Enum.with_index()
            |> Enum.each(fn {{champion, rarity}, index} ->
              holographic = randomize(rarity.holographic_rate)
              full_art = holographic && randomize(rarity.full_art_rate)

              Core.Gameplay.create_card!(%{
                holographic: holographic,
                full_art: full_art,
                champion: champion,
                season: season,
                rarity: rarity,
                position: index + 1
              })
            end)

            %{season_id: season.id}
            |> Core.Job.GeneratePacksJob.new()
            |> Oban.insert()
          end,
          timeout: 120_000
        )
    end
  end

  defp randomize(rate) do
    Utilities.List.random([{true, rate}, {false, 100.0 - rate}])
  end
end
