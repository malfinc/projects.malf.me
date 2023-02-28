defmodule Core.Job.GenerateCardsJob do
  @moduledoc """

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
            for rarity <- rarities, champion <- champions do
              for _ <- 1..rarity.season_pick_rate do
                Core.Gameplay.create_card!(%{
                  champion: champion,
                  season: season,
                  rarity: rarity
                })
              end
            end

            %{season_id: season.id}
            |> Core.Job.GeneratePacksJob.new()
            |> Oban.insert()
          end,
          timeout: 120_000
        )
    end
  end
end
