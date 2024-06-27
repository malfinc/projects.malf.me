defmodule CoreWeb.MatchLive do
  @moduledoc false
  use CoreWeb, :live_view

  import Ecto.Query

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_matches_by(fn matches ->
      from(
        match in matches,
        # Switch to assoc
        join: weekly in Core.Gameplay.Weekly,
        on: weekly.id == match.weekly_id,
        order_by: {:asc, weekly.position},
        preload: [
          :weekly,
          :season,
          division: [:conference],
          left_champion: [:upgrades, :plant],
          right_champion: [:upgrades, :plant],
          winning_champion: [:upgrades, :plant]
        ]
      )
    end)
    |> Enum.group_by(&Map.get(&1, :weekly))
    |> Enum.to_list()
    |> Enum.sort_by(fn {key, _} -> key.position end)
    |> Enum.map(fn {weekly, matches} ->
      {
        weekly,
        matches
        |> Enum.group_by(&Map.get(Map.get(&1, :division), :conference))
        |> Enum.map(fn {conference, matches} ->
          {conference, Enum.group_by(matches, &Map.get(&1, :division))}
        end)
      }
    end)
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.get_match(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([
          :weekly,
          :season,
          division: [:conference],
          left_champion: [:upgrades, :plant],
          right_champion: [:upgrades, :plant],
          winning_champion: [:upgrades, :plant]
        ])
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
    |> assign(:page_title, "Matches")
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
        |> assign(:page_title, "Match / #{record.id}")
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
    <h1>Matches</h1>
    <div :for={{weekly, matches_by_conference} <- @records} style="padding-left: 25px;">
      <h2>Week <%= weekly.position %></h2>
      <div
        :for={{conference, matches_by_division} <- matches_by_conference}
        style="padding-left: 25px;"
      >
        <h3><%= conference.name %> Conference</h3>
        <div :for={{division, matches} <- matches_by_division} style="padding-left: 25px;">
          <h4><%= division.name %> Division</h4>
          <ul>
            <li :for={match <- matches}>
              <%= Pretty.get(match, :name) %> (winner <%= match.winning_champion.name %>)
              <.link href={~p"/lop/matches/#{match.id}"}>View</.link>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1><%= Pretty.get(@record, :name) %></h1>
    <section style="display: grid; grid-template-columns: 3fr 1fr 3fr; place-items: center">
      <.champion
        champion={@record.left_champion}
        winner={@record.winning_champion == @record.left_champion}
      /> Vs
      <.champion
        champion={@record.right_champion}
        winner={@record.winning_champion == @record.right_champion}
      />
    </section>
    <p :for={round <- @record.rounds}>
      <%= round %>
    </p>
    """
  end
end
