defmodule Core.Job.GenerateWeekliesJob do
  @moduledoc """
  Generates the weekly fights that will be a part of each season.
  """
  use Oban.Worker
  @weekly_size 12

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    season_id
    |> Core.Gameplay.get_season()
    |> case do
      nil ->
        {:snooze, 15}

      season ->
        for _ <- 1..@weekly_size do
          Core.Gameplay.create_weekly!(%{season: season})
        end
    end
  end
end
