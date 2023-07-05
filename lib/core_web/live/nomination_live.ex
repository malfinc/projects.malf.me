defmodule CoreWeb.NominationLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(_assigns, params) do
    from(
      Core.Content.Nomination,
      where: [
        hall_id: ^params["hall_id"]
      ],
      preload: [:hall, :account]
    )
    |> Core.Repo.all()
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    records = list_records(socket.assigns, params)
    socket
    |> assign(:page_title, "Nominations")
    |> assign(:hall, Core.Content.get_hall!(params["hall_id"]))
    |> assign(:changeset, Core.Content.Nomination.changeset(%Core.Content.Nomination{}, %{}))
    |> assign(:query, params["query"])
    |> assign(:records, records)
    |> assign(:results, search_games(params["query"], records))
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("nominate", %{"id" => external_game_id, "box-art-url" => box_art_url, "name" => name}, socket) do
    Core.Content.create_nomination(%{
      hall: socket.assigns.hall,
      account: socket.assigns.current_account,
      name: name,
      box_art_url: box_art_url,
      external_game_id: external_game_id
    })
    |> case do
      {:ok, _} ->
        socket
        |> push_patch(to: ~p"/halls/#{socket.assigns.hall.id}/nominations")
      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
    end
    |> (&{:noreply, &1}).()
  end

  def handle_event("search", %{"query" => query}, socket) do
    socket
    |> push_patch(to: ~p"/halls/#{socket.assigns.hall.id}/nominations?query=#{query}")
    |> (&{:noreply, &1}).()
  end

  defp search_games(nil, _), do: []

  defp search_games(query, records) do
    if String.length(query) >= 3 do
      Core.Client.TwitchClient.search_games(query)
      |> case do
        {:ok, %{"data" => list}} -> list
        {:error, _} -> []
      end
    else
      []
    end
    |> Enum.map(fn item ->
      item
      |> Map.put(
        "box_art_url",
        item |> Map.get("box_art_url") |> String.replace(~r/\d+x\d+/, "300x415")
      )
      |> Map.put("nomination", records
        |> Enum.find(fn %{external_game_id: external_game_id} -> external_game_id == Map.get(item, "id") end)
      )
    end)
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any) => any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1>Nominations for <.link href={~p"/halls/#{@hall.id}"}><%= Pretty.get(@hall, :name) %></.link></h1>
    <.simple_form :let={f} for={%{"query" => @query}} phx-change="search">
      <.input field={{f, :query}} label="Search Games" type="text" phx-debounce="450" />
    </.simple_form>
    <div :if={length(@results) > 0} class="mt-3 mb-3 row row-cols-1 row-cols-md-4 g-4">
      <div :for={result <- @results} class="col">
        <div disabled class="card" id={result["id"]}>
          <div class="card-header text-center">
            <h6><strong><%= result["name"] %></strong></h6>
          </div>
          <div class="card-body text-center">
            <div class="d-grid gap-2">
              <.button :if={result["nomination"] && result["nomination"].state == "nominated"} usable_icon="square-check" disabled as="light">
                Nominated
              </.button>
              <.button :if={result["nomination"] && result["nomination"].state == "vetoed"} usable_icon="square-xmark" disabled as="danger">
                Vetoed
              </.button>
              <.button :if={result["nomination"] && result["nomination"].state == "completed"} usable_icon="circle-check" disabled as="success">
                Completed
              </.button>
              <.button :if={!result["nomination"]} usable_icon="check-to-slot" phx-click="nominate" phx-value-id={result["id"]} phx-value-box-art-url={result["box_art_url"]} phx-value-name={result["name"]}>
                Nominate
              </.button>
            </div>
          </div>
          <img src={result["box_art_url"]} class="card-img-bottom" alt="The box art for the game">
        </div>
      </div>
    </div>
    <div :if={length(@records) > 0} class="mt-3 mb-3 row row-cols-1 row-cols-md-4 g-4">
      <div :for={record <- @records} class="col">
        <div disabled class="card">
          <div class="card-header text-center">
            <h6><strong><%= record.name %></strong></h6>
            <%= if record.state == "vetoed" do %>
              Vetoed by MALF
            <% else %>
              Nominated by <%= record.account.username %>
            <% end %>
          </div>
          <img src={record.box_art_url} class="card-img-bottom" alt="The box art for the game">
        </div>
      </div>
    </div>
    """
  end
end
