defmodule Core.Job.StartSeasonJob do
  @moduledoc """
  After starting a season fill the season with capable champions and then put those champions into conferences and divisions.
  """
  use Oban.Worker
  require Logger

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          :ok | {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    season_id
    |> Core.Gameplay.get_season()
    |> Core.Repo.preload([:plants])
    |> case do
      nil ->
        {:snooze, 15}

      season ->
        Core.Repo.transaction(fn ->
          %{season_id: season.id}
          |> Core.Job.GenerateWeekliesJob.new()
          |> Oban.insert()

          %{season_id: season.id}
          |> Core.Job.GenerateChampionsJob.new()
          |> Oban.insert()
        end)
    end
  end
end
