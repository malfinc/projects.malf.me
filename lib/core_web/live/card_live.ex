defmodule CoreWeb.CardLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(assigns, _params) do
    assigns.current_season
    |> case do
      nil ->
        []

      season ->
        Core.Gameplay.list_cards_by(fn cards ->
          from(
            card in cards,
            where: [
              season_id: ^season.id,
              account_id: ^assigns.current_account.id
            ],
            # Switch to assoc()
            join: rarity in Core.Gameplay.Rarity,
            on: rarity.id == card.rarity_id,
            order_by: [
              rarity.season_pick_rate
            ],
            preload: [
              :season,
              :rarity,
              champion: [:plant, :upgrades]
            ]
          )
        end)
    end
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_pack(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([
          :season,
          :rarity,
          champion: [:plant, :upgrades]
        ])
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
        |> assign(:page_title, "Pack / #{record.champion.name} (#{record.rarity.name})")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any) => any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1>Collection</h1>

    <section class="collection collection--cards">
      <.battle_card :for={card <- @records} card={card} />
    </section>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1><%= @record.name %> (<%= @record.rarity.name %>)</h1>

    <.battle_card card={@record} />
    """
  end
end
