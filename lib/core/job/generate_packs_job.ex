defmodule Core.Job.GeneratePacksJob do
  @moduledoc """

  """
  use Oban.Worker

  @pack_size 6

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    season_id
    |> Core.Gameplay.get_season()
    |> case do
      nil ->
        {:snooze, 15}

      season ->
        Core.Repo.transaction(fn ->
          for _ <- 1..Core.Gameplay.count_cards()//@pack_size do
            Core.Gameplay.create_pack!(%{season: season})
          end
        end)

        %{season_id: season.id}
        |> Core.Job.FillPackSlotsJob.new()
        |> Oban.insert()
    end
  end
end
