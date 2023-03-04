defmodule Core.Job.FillConferencesJob do
  @moduledoc """
  Fills the divisions of conferences with champions who are ready to fight.
  """
  use Oban.Worker

  @pack_size 6

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    season_id
    |> Core.Gameplay.get_season()
    |> Core.Repo.preload([:weeklies])
    |> case do
      nil ->
        {:snooze, 15}

      season ->
        Core.Repo.transaction(fn ->
          # Turn a season into a list of champions, instead of getting all champions
          Core.Gameplay.list_champions()
          |> Enum.chunk_every(16)
          |> Enum.zip(Core.Gameplay.list_divisions())
          |> Enum.each(fn {chunk_of_champions, division} ->
            Enum.chunk_every(chunk_of_champions, 2)
            |> Enum.zip(season.weeklies)
            |> Enum.each(fn {[left_champion, right_champion], weekly} ->
              Core.Gameplay.create_match!(%{
                season: season,
                left_champion: left_champion,
                right_champion: right_champion,
                weekly: weekly,
                division: division
              })
            end)
          end)
        end)
    end
  end
end
