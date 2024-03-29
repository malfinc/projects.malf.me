defmodule Core.Job.GenerateChampionsJob do
  @moduledoc """
  Creates all the champions for each season.
  """
  use Oban.Worker

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    names =
      File.read!(Application.app_dir(:core, "priv/data/names.txt"))
      |> String.trim()
      |> String.split("\n")

    words =
      File.read!(Application.app_dir(:core, "priv/data/words.txt"))
      |> String.trim()
      |> String.split("\n")

    season_id
    |> Core.Gameplay.get_season()
    |> Core.Repo.preload([:plants])
    |> case do
      nil ->
        {:snooze, 15}

      season ->
        Core.Repo.transaction(fn ->
          season.plants
          |> Enum.zip(names(names, words, length(season.plants)))
          |> Enum.with_index()
          |> Enum.each(fn {{plant, name}, index} ->
            Core.Gameplay.create_champion!(%{plant: plant, name: name, position: index + 1})
          end)

          %{season_id: season.id}
          |> Core.Job.AllocateMatchesJob.new()
          |> Oban.insert()

          %{season_id: season.id}
          |> Core.Job.GenerateCardsJob.new()
          |> Oban.insert()
        end)
    end
  end

  defp names(names, words, size) do
    Utilities.Enum.multiple_unique(size, size, fn ->
      Utilities.String.titlecase("#{names |> Enum.random()} the #{words |> Enum.random()}")
    end)
    |> Enum.map(&Utilities.String.titlecase/1)
  end
end
