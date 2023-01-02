defmodule CoreWeb.SeasonLive do
  @moduledoc false
  use CoreWeb, :live_view

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_seasons()
    |> Core.Repo.preload([challenges: [champion: [:plant, :upgrades]]])
    |> Core.Decorate.deep()
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_season(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([challenges: [champion: [:plant, :upgrades]]])
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
    |> Core.Gameplay.create_season()
    |> case do
      {:ok, record} ->
        socket
        |> redirect(to: ~p"/lop/seasons/#{record.id}")

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

    <%= if length(@records) > 0 do %>
      <ul>
        <%= for season <- @records do %>
          <li><.link href={~p"/lop/seasons/#{season.id}"}>Season <%= season.position %></.link></li>
        <% end %>
      </ul>
    <% else %>
      <p>
        No seasons setup yet.
      </p>
    <% end %>

    <%= if Core.Users.has_permission?(@current_account, "global", "administrator") do %>
      <.simple_form :let={_f} for={@changeset} id="new_season" phx-submit="create_season">
        <:actions>
          <.button phx-disable-with="Starting..." type="submit" class="btn btn-primary">
            Start New Season
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

    <h2>Challenges</h2>
    <%= if length(@record.challenges) > 0 do %>
      <ul>
        <%= for challenge <- @record.challenges do %>
          <li>
            <.link href={~p"/lop/challenges/#{challenge.id}"}><%= challenge.id %></.link>

            <h3>Participants</h3>
            <%= if length(challenge.champions) > 0 do %>
              <ul>
                <%= for champion <- @record.champions do %>
                  <li>
                    <.link href={~p"/lop/champions/#{champion.id}"}>
                      <%= champion.name %>
                    </.link>
                  </li>
                <% end %>
              </ul>
            <% else %>
              <p>
                No champions yet participating in this challenge.
              </p>
            <% end %>
          </li>
        <% end %>
      </ul>
    <% else %>
      <p>
        No challenges created for this season yet.
      </p>
    <% end %>
    """
  end
end
