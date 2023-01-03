defmodule CoreWeb.ChampionLive do
  @moduledoc false
  use CoreWeb, :live_view

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_champions()
    |> Core.Repo.preload([:upgrades, :plant])
    |> Core.Decorate.deep()
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_champion(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([:upgrades, :plant])
        |> Core.Decorate.deep()
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Champion")
    |> assign(:changeset, Core.Gameplay.Champion.changeset(%Core.Gameplay.Champion{}, %{}))
  end

  defp as(socket, :list, params) do
    socket
    |> assign(:page_title, "Champions")
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
        |> assign(:page_title, "Champion / #{record.name}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("create_champion", params, socket) do
    params
    |> Core.Gameplay.create_champion()
    |> case do
      {:ok, record} ->
        socket
        |> redirect(to: ~p"/lop/champions/#{record.id}")

      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :list} = assigns) do
    ~H"""

    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1><%= @record.name %> (Alive)</h1>
    <p><%= @record.name %> is a <%= @record.plant.species %>.</p>
    <dl>
      <%= for {name, value} <- total_attributes(@record) do %>
        <dt><%= Utilities.String.titlecase(name) %></dt>
        <dd><%= value %></dd>
      <% end %>
    </dl>
    """
  end

  defp total_attributes(%{upgrades: upgrades, plant: %{starting_attributes: starting_attributes}}) do
    Enum.reduce(upgrades, starting_attributes, fn upgrade, attributes ->
      Map.merge(attributes, Map.take(upgrade, Map.keys(attributes)))
    end)
  end
end
