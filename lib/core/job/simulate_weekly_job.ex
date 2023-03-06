defmodule Core.Job.SimulateWeeklyJob do
  @moduledoc """
  Fills the divisions of conferences with champions who are ready to fight.
  """
  use Oban.Worker

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"weekly_id" => weekly_id}}) do
    weekly_id
    |> Core.Gameplay.get_weekly()
    |> Core.Repo.preload(matches: [:left_champion, :right_champion, :winning_champion])
    |> case do
      nil ->
        {:snooze, 15}

      weekly ->
        Core.Repo.transaction(fn ->
          for match <- weekly.matches do
            rounds = Core.Gameplay.fight(match)

            {winning_champion, _log} = List.last(rounds)

            Core.Gameplay.update_match!(match, %{
              winning_champion: winning_champion,
              rounds: Enum.map(rounds, fn {_champion, log} -> log end)
            })
          end

          %{season_id: weekly.season_id}
          |> Core.Job.AllocateMatchesJob.new()
          |> Oban.insert()
        end)
    end
  end
end
