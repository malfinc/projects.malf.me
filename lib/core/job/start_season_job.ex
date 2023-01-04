defmodule Core.Job.StartSeasonJob do
  @moduledoc """
  After starting a season fill the season with capable champions and then put those champions into conferences and divisions.
  """
  use Oban.Worker

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          :ok | {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    words = File.read!("priv/data/words.txt") |> String.split("\n")

    Core.Gameplay.get_season(season_id)
    |> Core.Repo.preload([:plants])
    |> case do
      nil ->
        {:snooze, 60}

      season ->
        IO.puts("Start season!")

        Utilities.Enum.times(64, fn ->
          Core.Gameplay.create_champion(%{plant: plant(season), name: name(words)})
        end)

        :ok
    end
  end

  defp plant(season) do
    season.plants |> Enum.random()
  end

  defp name(words) do
    Utilities.Enum.multiple_unique(2, 2, fn ->
      words |> Enum.random()
    end)
    |> Enum.join(" ")
    |> Utilities.String.titlecase()
  end
end
