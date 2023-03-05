defmodule Core.Job.AllocateMatchesJob do
  @moduledoc """
  Fills the divisions of conferences with champions who are ready to fight.
  """
  use Oban.Worker

  import Ecto.Query

  @conference_size 16

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
        first_weekly =
          List.first(
            Core.Gameplay.list_weeklies(fn weeklies ->
              from(weeklies, order_by: {:asc, :position})
            end)
          )

        Core.Repo.transaction(fn ->
          # Turn a season into a list of champions, instead of getting all champions
          Core.Gameplay.list_champions()
          |> Enum.chunk_every(@conference_size)
          |> Enum.zip(Core.Gameplay.list_divisions())
          |> Enum.each(fn {chunk_of_champions, division} ->
            chunk_of_champions
            |> Enum.chunk_every(2)
            |> Enum.each(fn [left_champion, right_champion] ->
              Core.Gameplay.create_match!(%{
                season: season,
                left_champion: left_champion,
                right_champion: right_champion,
                weekly: first_weekly,
                division: division
              })
            end)
          end)
        end)
    end
  end
end
