defmodule CoreWeb.PlantLive do
  @moduledoc false
  use CoreWeb, :live_view

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_plants()
    |> Core.Repo.all()
    |> Core.Repo.preload([:champions])
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_plant(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([:champions])
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
        |> put_flash(:info, "Plant #{record.name} created")
        |> redirect(to: ~p"/lop/plants")

      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any) => any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1>Plants</h1>
    <%= if length(@records) > 0 do %>
      <ul>
        <%= for plant <- @records do %>
          <li>
            <.link href={~p"/lop/plants/#{plant.id}"}>
              <%= plant.name %> (<em><%= plant.species %></em>)
            </.link>
          </li>
        <% end %>
      </ul>
    <% else %>
      <p>
        No seasons setup yet.
      </p>
    <% end %>

    <%= if Core.Users.has_permission?(@current_account, "global", "administrator") do %>
      <.simple_form :let={f} for={@changeset} id="new_plant" phx-submit="create_plant">
        <.input field={{f, :name}} name="name" id="name" type="text" label="Name" required />
        <.input
          field={{f, :species}}
          name="species"
          id="species"
          type="text"
          label="Species"
          required
        />
        <.input
          field={{f, :image_uri}}
          name="image_uri"
          id="image_uri"
          type="text"
          label="Image URI"
          required
        />
        <.input
          field={{f, :rarity_symbol}}
          name="rarity_symbol"
          id="rarity_symbol"
          type="text"
          label="Rarity Symbol (SVG)"
          required
        />
        <:actions>
          <.button phx-disable-with="Planting..." type="submit" class="btn btn-primary" usable_icon="plant">
            Spawn Plant
          </.button>
        </:actions>
      </.simple_form>
    <% end %>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1>Plant <%= @record.name %></h1>
    <img src={@record.image_uri} />
    <dl>
      <dt>Name</dt>
      <dd><%= @record.name %></dd>
      <dt>Species</dt>
      <dd><%= @record.species %></dd>
    </dl>

    <h2>Champions</h2>
    <ul>
      <%= for champion <- @record.champions do %>
        <li>
          <.link href={~p"/lop/champions/#{champion.id}"}><%= champion.name %></.link>
        </li>
      <% end %>
    </ul>
    """
  end
end
