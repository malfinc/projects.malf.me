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
        |> Core.Repo.preload(
          cards: [:champion, :rarity],
          season: []
        )
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
          cards: [:champion, :rarity],
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
    Core.Gameplay.purchase_packs(
      assigns.current_season,
      assigns.current_account,
      String.to_integer(amount)
    )

    socket
    |> push_patch(to: ~p"/lop/packs")
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("open_pack", %{"id" => id}, socket) do
    Core.Gameplay.get_pack(id)
    |> case do
      nil ->
        socket

      pack ->
        Core.Gameplay.update_pack(pack, %{opened: true})
        |> case do
          {:ok, pack} ->
            socket
            |> push_patch(to: ~p"/lop/packs/#{id}")
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
        style="display: grid; grid-template-columns: repeat(auto-fit, 350px); gap: 15px; align-items: center; justify-items: center;"
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

    <section>
      <%= for card <- @record.cards do %>
        <section>
          <%= card.champion.name %> (<%= card.rarity.name %>)
        </section>
      <% end %>
    </section>
    """
  end
end
