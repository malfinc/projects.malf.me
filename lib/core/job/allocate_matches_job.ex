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
        Core.Repo.transaction(fn ->
          from(
            weekly in Core.Gameplay.Weekly,
            order_by: {:desc, :position},
            limit: 1,
            preload: [matches: [:winning_champion]]
          )
          |> Core.Repo.one()
          |> case do
            nil ->
              {0, Core.Gameplay.list_champions()}

            %{matches: matches, position: position} ->
              {
                position,
                Enum.map(matches, &Map.get(&1, :winning_champion))
              }
          end
          |> case do
            {_latest_position, []} ->
              :error

            {_latest_position, [_winning_champion]} ->
              :ok

            {latest_position, champion_pool} ->
              current_weekly =
                Core.Gameplay.create_weekly!(%{
                  season: season,
                  position: latest_position + 1
                })

              champion_pool
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
                    weekly: current_weekly,
                    division: division
                  })
                end)
              end)

              %{weekly_id: current_weekly.id}
              |> Core.Job.SimulateWeeklyJob.new()
              |> Oban.insert()
          end
        end)
    end
  end
end
