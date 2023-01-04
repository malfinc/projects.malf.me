defmodule Core.Job.DepositCoinJob do
  @moduledoc """
  Updates a user's bank with a change in value.
  """
  use Oban.Worker
  import Ecto.Query

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) ::
          {:ok, Core.Gameplay.Coin.t()} | {:error, Ecto.Changeset.t()} | {:snooze, pos_integer()}
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
        {:snooze, 86400}

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
        {:snooze, 86400}

      account ->
        Core.Gameplay.create_coin_transaction(%{
          account: account,
          value: value,
          reason: "unknown"
        })
    end
  end
end
