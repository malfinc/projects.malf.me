defmodule CoreWeb.AccountSettingsLive do
  use CoreWeb, :live_view
  import Ecto.Query

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1>Account</h1>
    <h2 id="wallet">Wallet</h2>
    <p>
      You currently have <.icon as="fa-coins" /> <%= :erlang.float_to_binary(@total_balance, decimals: 2) %> coins
    </p>

    <h3 id="transactions">Transactions</h3>
    <%= if length(@coin_transactions) > 0 do %>
      <ul>
        <li :for={{reason, value} <- @coin_transactions}>
          <.icon as="fa-coins" /> <%= :erlang.float_to_binary(value,
            decimals: 2
          ) %>
          <em>for <%= reason %></em>
        </li>
      </ul>
    <% else %>
      <p>You have no coin transactions currently.</p>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Core.Repo.preload([:coin_transactions])

    socket =
      socket
      |> assign(:current_account, account)
      |> assign(
        :total_balance,
        Enum.reduce(account.coin_transactions, 0.0, fn %{value: value}, total -> total + value end)
      )
      |> assign(
        :coin_transactions,
        Core.Gameplay.list_coin_transactions(fn coins ->
          from(
            coins,
            where: [
              account_id: ^account.id
            ],
            order_by: [
              {:desc, :inserted_at}
            ]
          )
        end)
        |> Enum.reduce([], fn coin_transaction, aggregated_statements ->
          Utilities.List.snip(aggregated_statements, -1)
          |> case do
            {[], []} ->
              Utilities.List.append(
                aggregated_statements,
                {coin_transaction.reason, coin_transaction.value}
              )

            {remaining_aggregated_statements, [{reason, previous_value}]} ->
              if reason == coin_transaction.reason do
                Utilities.List.append(
                  remaining_aggregated_statements,
                  {reason, previous_value + coin_transaction.value}
                )
              else
                Utilities.List.append(
                  aggregated_statements,
                  {coin_transaction.reason, coin_transaction.value}
                )
              end
          end
        end)
      )

    {:ok, socket}
  end
end
