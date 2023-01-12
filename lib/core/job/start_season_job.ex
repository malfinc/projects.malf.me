defmodule Core.Job.StartSeasonJob do
  @moduledoc """
  After starting a season fill the season with capable champions and then put those champions into conferences and divisions.
  """
  use Oban.Worker

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          :ok | {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    words = File.read!(Application.app_dir(:core, "priv/data/words.txt")) |> String.split("\n")

    Core.Gameplay.get_season(season_id)
    |> Core.Repo.preload([:plants])
    |> case do
      nil ->
        {:snooze, 60}

      season ->
        Core.Repo.transaction(fn ->
          Utilities.Enum.times(64, fn ->
            Core.Gameplay.create_champion!(%{plant: plant(season), name: name(words)})
          end)
          |> Enum.chunk_every(8)
          |> Enum.map(fn champions ->
            {
              Core.Gameplay.create_pack!(%{
                season: season
              }),
              champions
            }
          end)
          |> Enum.flat_map(fn {pack, champions} ->
            Enum.map(champions, fn champion ->
              {pack, champion}
            end)
          end)
          |> Enum.each(fn {pack, champion} ->
            Core.Gameplay.create_pack_slot!(%{
              pack: pack,
              champion: champion
            })
          end)
        end)
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
