defmodule Core.Job.GeneratePacksJob do
  @moduledoc """
  Creates all the packs for the season, to be later stuffed.
  """
  use Oban.Worker

  @pack_size 6

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    season_id
    |> Core.Gameplay.get_season()
    |> case do
      nil ->
        {:snooze, 15}

      season ->
        Core.Repo.transaction(fn ->
          for {_, index} <- Enum.with_index(1..Core.Gameplay.count_cards()//@pack_size) do
            Core.Gameplay.create_pack!(%{season: season, position: index + 1})
          end
        end)

        %{season_id: season.id}
        |> Core.Job.FillPackSlotsJob.new()
        |> Oban.insert()
    end
  end
end
