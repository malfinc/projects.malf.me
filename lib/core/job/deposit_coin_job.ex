defmodule Core.Job.DepositCoinJob do
  @moduledoc """
  Updates a user's bank with a change in value.
  """
  use Oban.Worker
  import Ecto.Query
  require Logger

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          {:ok, Core.Gameplay.CoinTransaction.t()} | {:error, Ecto.Changeset.t()}
  def perform(%Oban.Job{args: %{"twitch_user_id" => nil}}) do
    {:cancel, "No twitch_user_id given, we can't allocate points"}
  end

  def perform(%Oban.Job{
        args: %{"twitch_user_id" => twitch_user_id, "value" => value, "reason" => reason}
      }) do
    from(
      accounts in Core.Users.Account,
      where: accounts.provider_id == ^twitch_user_id,
      limit: 1
    )
    |> Core.Repo.one()
    |> case do
      nil ->
        {:snooze, 86_400}

      account ->
        Core.Gameplay.create_coin_transaction(%{
          account: account,
          value: value,
          reason: reason
        })
    end
  end

  def perform(%Oban.Job{args: %{"twitch_user_id" => twitch_user_id, "value" => value}}) do
    from(
      accounts in Core.Users.Account,
      where: accounts.provider_id == ^twitch_user_id,
      limit: 1
    )
    |> Core.Repo.one()
    |> case do
      nil ->
        {:snooze, 86_400}

      account ->
        Core.Gameplay.create_coin_transaction(%{
          account: account,
          value: value,
          reason: "unknown"
        })
    end
  end
end
