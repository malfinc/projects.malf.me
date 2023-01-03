defmodule Core.Job.InitiateChallengeJob do
  @moduledoc """
  Find two champions who should fight.
  """
  use Oban.Worker

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          {:ok, Core.Gameplay.Challenge.t()} | {:error, Ecto.Changeset.t()} | {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"season_id" => season_id}}) do
    Core.Gameplay.list_champions()
    |>
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
