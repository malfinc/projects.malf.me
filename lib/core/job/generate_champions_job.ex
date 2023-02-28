defmodule Core.Job.GenerateChampionsJob do
  @moduledoc """

  """
  use Oban.Worker
  @champion_pool_size 64

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
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
          for name <- names(words) do
            Core.Gameplay.create_champion!(%{plant: plant(season), name: name})
          end

          %{season_id: season.id}
          |> Core.Job.GenerateCardsJob.new()
          |> Oban.insert()
        end)
    end
  end

  defp plant(season) when is_struct(season, Core.Gameplay.Season) do
    season.plants |> Enum.random()
  end

  defp names(words) do
    Utilities.Enum.multiple_unique(@champion_pool_size, @champion_pool_size, fn ->
      "#{words |> Enum.random()} #{words |> Enum.random()}"
    end)
    |> Enum.map(&Utilities.String.titlecase/1)
  end
end
