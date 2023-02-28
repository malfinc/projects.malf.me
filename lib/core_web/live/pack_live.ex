defmodule CoreWeb.PackLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_packs()
    |> Core.Repo.preload(
      cards: [:champion, :rarity],
      season: []
    )
    |> Core.Decorate.deep()
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
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    socket
    |> assign(:page_title, "Packs")
    |> assign(:plants,
      Core.Gameplay.Pack
      |> from(
        where: [
          opened: false,
          season_id: ^Core.Gameplay.current_season_id(),
          account_id: ^socket.assigns.current_account.id
        ]
      )
      |> Core.Repo.all()
    )
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
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1>Unopened Packs</h1>

    <%= if Enum.any?(@records) do %>
      <section
        id="UnopenedCardPacks"
        phx-hook="UnopenedCardPacks"
        style="display: grid; grid-template-columns: repeat(auto-fit, 350px); gap: 15px; align-items: center; justify-items: center;"
      >
        <%= for pack <- @record do %>
          <.card_pack pack={pack} />
        <% end %>
      </section>
    <% end %>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1>Opened Pack</h1>
    """
  end
end
