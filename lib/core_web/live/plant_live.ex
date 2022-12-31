defmodule CoreWeb.PlantLive do
  @moduledoc false
  use CoreWeb, :live_view

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_plants()
    |> Core.Repo.preload([:champions])
    |> Core.Decorate.deep()
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_plant(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([:champions])
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
    |> assign(:page_title, "Plants")
    |> assign(:changeset, Core.Gameplay.Plant.changeset(%Core.Gameplay.Plant{}, %{}))
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
        |> assign(:page_title, "Plant / #{record.name}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("create_plant", params, socket) do
    params
    |> Core.Gameplay.create_plant()
    |> case do
      {:ok, record} ->
        socket
        |> redirect(to: ~p"/plants/#{record.id}")

      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1>Plants</h1>
    <ul>
      <%= for plant <- @records do %>
        <li>
          <.link href={~p"/plants/#{plant.id}"}><%= plant.name %> (<%= plant.rarity %>)</.link>
        </li>
      <% end %>
    </ul>
    <.simple_form :let={f} for={@changeset} id="new_plant" phx-submit="create_plant">
      <.input field={{f, :name}} name="name" id="name" type="text" label="Name" required />
      <.input
        field={{f, :rarity}}
        name="rarity"
        id="rarity"
        type="select"
        label="Rarity"
        prompt="Select one..."
        options={rarity_options()}
        required
      />
      <:actions>
        <.button phx-disable-with="Planting..." type="submit" class="btn btn-primary">
          Spawn Plant
        </.button>
      </:actions>
    </.simple_form>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1>Plant <%= @record.name %></h1>
    <dl>
      <dt>Name</dt>
      <dd><%= @record.name %></dd>
      <dt>Rarity</dt>
      <dd><%= @record.rarity %></dd>
    </dl>

    <h2>Champions</h2>
    <ul>
      <%= for champion <- @record.champions do %>
        <li><%= champion.name %></li>
      <% end %>
    </ul>
    """
  end

  defp rarity_options(),
    do: [
      {"Normal", "normal"},
      {"Rare", "rare"},
      {"Epic", "epic"}
    ]
end
