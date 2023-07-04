defmodule CoreWeb.SeasonLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_seasons(fn schema -> order_by(schema, [asc: :position]) end)
    # |> Core.Repo.preload()
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_season(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload(champions: [:plant])
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
    |> assign(:plants, Core.Gameplay.list_plants())
    |> assign(
      :changeset,
      Core.Gameplay.Season.changeset(%Core.Gameplay.Season{} |> Core.Repo.preload([:plants]), %{})
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
        |> assign(:page_title, "Season / #{record.position}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("activate", _params, %{assigns: %{record: %{__source__: source}}} = socket) do
    Core.Gameplay.update_season(source, %{active: true})
    |> case do
      {:ok, record} ->
        socket
        |> assign(:record, record)
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("create_season", params, socket) do
    with {:ok, season} <-
           Core.Gameplay.create_season(%{
             plants:
               Enum.reduce(params["plants"], [], fn
                 {_id, "false"}, selected_plants -> selected_plants
                 {id, "true"}, selected_plants -> [Core.Gameplay.get_plant(id) | selected_plants]
               end)
           }),
         {:ok, _job} <- Oban.insert(Core.Job.StartSeasonJob.new(%{season_id: season.id})) do
      socket
      |> redirect(to: ~p"/lop/seasons/#{season.id}")
    else
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
    <h1>Seasons</h1>

    <%= if length(@records) > 0 do %>
      <ul>
        <%= for season <- @records do %>
          <li>
            <.link href={~p"/lop/seasons/#{season.id}"}>Season <%= season.position %></.link>
          </li>
        <% end %>
      </ul>
    <% else %>
      <p>
        No seasons setup yet.
      </p>
    <% end %>

    <%= if Core.Users.has_permission?(@current_account, "global", "administrator") do %>
      <h2>New Season</h2>
      <.simple_form :let={f} for={@changeset} id="new_season" phx-submit="create_season">
        <%= for plant <- @plants do %>
          <.input
            field={{f, :plants}}
            type="checkbox"
            checked={false}
            id={"plants_#{plant.slug}"}
            name={"plants[#{plant.id}]"}
            label={plant.name}
          />
        <% end %>

        <:actions>
          <.button phx-disable-with="Starting..." type="submit" class="btn btn-primary" usable_icon="fireworks">
            Start Season
          </.button>
        </:actions>
      </.simple_form>
    <% end %>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1>Season <%= @record.position %></h1>

    <section>
      <button class="btn btn-primary" type="button" disabled={@record.active} phx-click="activate">
        Activate
      </button>
    </section>

    <h2>Champions</h2>
    <ul>
      <%= for champion <- @record.champions do %>
        <li>
          <.link href={~p"/lop/champions/#{champion.id}"}><%= champion.name %></.link>
          (<%= champion.plant.name %>)
        </li>
      <% end %>
    </ul>
    """
  end
end
