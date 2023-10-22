defmodule CoreWeb.AccountSettingsLive do
  use CoreWeb, :live_view
  import Ecto.Query

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
        <%= for {reason, value} <- @coin_transactions do %>
          <li>
            <.icon as="fa-coins" /> <%= :erlang.float_to_binary(value,
              decimals: 2
            ) %>
            <em>for <%= reason %></em>
          </li>
        <% end %>
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
        (coin_transaction in Core.Gameplay.CoinTransaction)
        |> from(
          where: [
            account_id: ^account.id
          ],
          order_by: [
            {:desc, :inserted_at}
          ]
        )
        |> Core.Repo.all()
        |> Enum.reduce([], fn coin_transcation, aggregated_statements ->
          Utilities.List.snip(aggregated_statements, -1)
          |> case do
            {[], []} ->
              Utilities.List.append(
                aggregated_statements,
                {coin_transcation.reason, coin_transcation.value}
              )

            {remaining_aggregated_statements, [{reason, previous_value}]} ->
              if reason == coin_transcation.reason do
                Utilities.List.append(
                  remaining_aggregated_statements,
                  {reason, previous_value + coin_transcation.value}
                )
              else
                Utilities.List.append(
                  aggregated_statements,
                  {coin_transcation.reason, coin_transcation.value}
                )
              end
          end
        end)
      )

    {:ok, socket}
  end
end
