defmodule CoreWeb.SeasonLive do
  @moduledoc false
  use CoreWeb, :live_view

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_seasons()
    |> Core.Repo.preload(seasonal_statistics: [champion: [:plant, :upgrades]])
    |> Core.Decorate.deep()
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_season(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload(seasonal_statistics: [champion: [:plant, :upgrades]])
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
    |> assign(:page_title, "Seasons")
    |> assign(:changeset, Core.Gameplay.Season.changeset(%Core.Gameplay.Season{}, %{}))
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
        |> assign(:page_title, "Season / #{record.id}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("create_season", params, socket) do
    params
    |> Map.put(
      "position",
      socket.assigns.records
      |> Utilities.List.pluck(:position)
      |> List.last()
      |> Kernel.||(0)
      |> Kernel.+(1)
    )
    |> Core.Gameplay.create_season()
    |> case do
      {:ok, record} ->
        socket
        |> redirect(to: ~p"/seasons/#{record.id}")

      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1>Seasons</h1>
    <.simple_form :let={_f} for={@changeset} id="new_season" phx-submit="create_season">
      <:actions>
        <.button phx-disable-with="Starting..." type="submit" class="btn btn-primary">
          Start New Season
        </.button>
      </:actions>
    </.simple_form>

    <ul>
      <%= for season <- @records do %>
        <li>Season <%= season.position %></li>
      <% end %>
    </ul>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1>Season <%= @record.position %></h1>

    <h2>Scoreboard</h2>
    <ul>
      <%= for seasonal_statistic <- sorted(@record.seasonal_statistics) do %>
        <li>
          <%= seasonal_statistic.champion.name %> <%= seasonal_statistic.wins %> Wins, <%= seasonal_statistic.losses %> Losses
        </li>
      <% end %>
    </ul>
    """
  end

  defp sorted(seasonal_statistics) do
    seasonal_statistics
  end
end
