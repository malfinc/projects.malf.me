defmodule CoreWeb.PackLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(assigns, _params) do
    assigns.current_season
    |> case do
      nil ->
        []

      season ->
        Core.Gameplay.Pack
        |> from(
          where: [
            opened: false,
            season_id: ^season.id,
            account_id: ^assigns.current_account.id
          ]
        )
        |> Core.Repo.all()
        |> Core.Repo.preload([
          :cards,
          :season
        ])
        |> Core.Decorate.deep()
    end
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_pack(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload(
          cards: [champion: [:plant, :upgrades], rarity: []],
          season: []
        )
        |> Core.Decorate.deep()
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> assign(:current_season, Core.Gameplay.current_season())
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    socket
    |> assign(:page_title, "Packs")
    |> assign(:records, list_records(socket.assigns, params))
  end

  defp as(socket, :show, %{"id" => id}) when is_binary(id) do
    get_record(id)
    |> case do
      {:error, :not_found} ->
        raise CoreWeb.Exceptions.NotFoundException

      record ->
        socket
        |> assign(:record, record)
        |> assign(:page_title, "Pack / #{record.id}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("purchase_packs", %{"amount" => amount}, %{assigns: assigns} = socket) do
    results =
      Core.Gameplay.purchase_packs(
        assigns.current_season,
        Core.Repo.preload(assigns.current_account, :coin_transactions),
        String.to_integer(amount)
      )

    dbg(results)

    socket
    |> push_patch(to: ~p"/lop/packs")
    |> put_flash(
      :error,
      results
      |> Enum.filter(fn
        {:error, _} -> true
        {:ok, _} -> false
      end)
      |> Enum.map(fn {_, message} -> message end)
    )
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "open_pack",
        %{"id" => id},
        %{assigns: %{current_account: current_account}} = socket
      ) do
    Core.Gameplay.get_pack(id)
    |> Core.Repo.preload(cards: [:account])
    |> case do
      nil ->
        socket

      pack ->
        Core.Gameplay.open_pack(pack, current_account)
        |> case do
          {:ok, _transaction} ->
            socket
            |> push_navigate(to: ~p"/lop/packs/#{pack.id}")
        end
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any) => any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1>Unopened Packs</h1>

    <section class="btn-group" role="group" aria-label="Purchase packs">
      <button type="button" class="btn btn-primary" phx-click="purchase_packs" phx-value-amount={1}>
        Purchase 1 Pack
      </button>
      <button type="button" class="btn btn-primary" phx-click="purchase_packs" phx-value-amount={2}>
        2 Packs
      </button>
      <button type="button" class="btn btn-primary" phx-click="purchase_packs" phx-value-amount={6}>
        6 Packs
      </button>
      <button type="button" class="btn btn-primary" phx-click="purchase_packs" phx-value-amount={15}>
        15 Packs
      </button>
    </section>

    <hr />

    <%= if Enum.any?(@records) do %>
      <section
        id="UnopenedCardPacks"
        phx-hook="UnopenedCardPacks"
        class="collection collection--packs"
      >
        <%= for pack <- @records do %>
          <.card_pack pack={pack} />
        <% end %>
      </section>
    <% else %>
      <p>You have no unopened packs.</p>
    <% end %>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1>Opened Pack</h1>

    <section class="collection collection--cards">
      <%= for card <- @record.cards do %>
        <section>
          <.card card={card} />
        </section>
      <% end %>
    </section>
    """
  end
end
