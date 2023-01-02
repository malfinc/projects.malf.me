defmodule Core.Job.DepositCoinJob do
  @moduledoc """
  Updates a user's bank with a change in value.
  """
  use Oban.Worker
  import Ecto.Query

  @impl Oban.Worker
  @spec perform(Oban.Job.t()) :: {:ok, Core.Gameplay.Coin.t()} | {:error, Ecto.Changeset.t()}
  def perform(%Oban.Job{args: %{"twitch_user_id" => twitch_user_id, "value" => value}}) do
    account = from(
      accounts in Core.Users.Account,
      where: accounts.provider_id == ^twitch_user_id,
      limit: 1
    )
    |> Core.Repo.one()

    Core.Gameplay.create_coin_transaction(%{
      account: account,
      value: value
    })
  end
end
