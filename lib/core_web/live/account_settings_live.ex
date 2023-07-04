defmodule CoreWeb.AccountSettingsLive do
  use CoreWeb, :live_view
  import Ecto.Query

  def render(assigns) do
    ~H"""
    <h1>Account</h1>
    <h2 id="wallet">Wallet</h2>
    <p>
      You currently have
      <.icon as="fa-coins" /> <%= :erlang.float_to_binary(@total_balance, decimals: 2) %> coins
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

    <h2>Change Email</h2>
    <.simple_form
      :let={f}
      id="email_form"
      for={@email_changeset}
      phx-submit="update_email"
      phx-change="validate_email"
    >
      <.error :if={@email_changeset.action == :insert}>
        Oops, something went wrong! Please check the errors below.
      </.error>

      <.input field={{f, :email_address}} type="email" label="Email" required />

      <.input
        field={{f, :current_password}}
        name="current_password"
        id="current_password_for_email"
        type="password"
        label="Current password"
        value={@email_form_current_password}
        required
      />
      <:actions>
        <.button phx-disable-with="Changing..." type="submit" class="btn btn-primary" usable_icon="save">
          Change Email Address
        </.button>
      </:actions>
    </.simple_form>

    <h2>Change Password</h2>

    <.simple_form
      :let={f}
      id="password_form"
      for={@password_changeset}
      action={~p"/accounts/log_in?_action=password_updated"}
      method="post"
      phx-change="validate_password"
      phx-submit="update_password"
      phx-trigger-action={@trigger_submit}
    >
      <.error :if={@password_changeset.action == :insert}>
        Oops, something went wrong! Please check the errors below.
      </.error>

      <.input field={{f, :email_address}} type="hidden" value={@current_email} />

      <.input field={{f, :password}} type="password" label="New password" required />
      <.input field={{f, :password_confirmation}} type="password" label="Confirm new password" />
      <.input
        field={{f, :current_password}}
        name="current_password"
        type="password"
        label="Current password"
        id="current_password_for_password"
        value={@current_password}
        required
      />
      <:actions>
        <.button phx-disable-with="Changing..." type="submit" class="btn btn-primary" usable_icon="save">
          Change Password
        </.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Core.Users.update_account_email_address(socket.assigns.current_account, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/accounts/settings")}
  end

  def mount(_params, _session, socket) do
    account = socket.assigns.current_account |> Core.Repo.preload([:coin_transactions])

    socket =
      socket
      |> assign(:current_account, account)
      |> assign(:current_password, nil)
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
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, account.email_address)
      |> assign(:email_changeset, Core.Users.change_account_email_address(account))
      |> assign(:password_changeset, Core.Users.change_account_password(account))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "account" => account_params} = params

    email_changeset =
      Core.Users.change_account_email_address(socket.assigns.current_account, account_params)

    socket =
      assign(socket,
        email_changeset: Map.put(email_changeset, :action, :validate),
        email_form_current_password: password
      )

    {:noreply, socket}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "account" => account_params} = params
    account = socket.assigns.current_account

    case Core.Users.apply_account_email_address(account, password, account_params) do
      {:ok, applied_account} ->
        Core.Users.deliver_account_update_email_address_instructions(
          applied_account,
          account.email_address,
          &url(~p"/accounts/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, put_flash(socket, :info, info)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "account" => account_params} = params

    password_changeset =
      Core.Users.change_account_password(socket.assigns.current_account, account_params)

    {:noreply,
     socket
     |> assign(:password_changeset, Map.put(password_changeset, :action, :validate))
     |> assign(:current_password, password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "account" => account_params} = params
    account = socket.assigns.current_account

    case Core.Users.update_account_password(account, password, account_params) do
      {:ok, account} ->
        socket =
          socket
          |> assign(:trigger_submit, true)
          |> assign(
            :password_changeset,
            Core.Users.change_account_password(account, account_params)
          )

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :password_changeset, changeset)}
    end
  end
end
