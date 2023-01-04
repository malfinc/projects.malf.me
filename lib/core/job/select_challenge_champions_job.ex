defmodule Core.Job.SelectChallengeChampionsJob do
  @moduledoc """
  Find all the pairings of champions.
  """
  use Oban.Worker

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          :ok
          | {:snooze, pos_integer()}
  def perform(%Oban.Job{args: %{"challenge_id" => challenge_id}}) do
    Core.Gameplay.get_challenge(challenge_id)
    |> Core.Repo.preload([:champions])
    |> case do
      nil ->
        {:snooze, 120}

      challenge ->
        challenge.champions
        |> Enum.shuffle()
        |> Enum.chunk_every(2)
        |> Enum.each(fn [left, right] ->
          Core.Gameplay.create_match(%{
            challenge: challenge,
            left_champion: left,
            right_champion: right
          })
        end)
    end
  end
end
