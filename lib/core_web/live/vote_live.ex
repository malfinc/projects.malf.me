defmodule CoreWeb.VoteLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(_assigns, params) do
    from(
      Core.Content.Nomination,
      where: [
        hall_id: ^params["hall_id"],
        state: "nominated"
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
    |> assign(:page_title, "Votes")
    |> assign(:hall, Core.Content.get_hall!(params["hall_id"]))
    |> assign(:changeset,
      %Core.Content.Vote{}
      |> Core.Repo.preload([:primary_nomination, :secondary_nomination, :tertiary_nomination])
      |> Ecto.Changeset.change(%{})
    )
    |> assign(:records, records)
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("unpick_priority", %{"value" => value} = params, socket) when is_binary(value), do: handle_event("unpick_priority", %{params | "value" => String.to_atom(value)}, socket)
  def handle_event("unpick_priority", %{"value" => value}, socket) do
    socket
    |> assign(:changeset,
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(value, nil)
    )
    |> (&{:noreply, &1}).()
  end

  def handle_event("pick_priority", %{"value" => value} = params, socket) when is_binary(value), do: handle_event("pick_priority", %{params | "value" => String.to_atom(value)}, socket)
  def handle_event("pick_priority", %{"id" => id, "value" => value}, socket) do
    socket
    |> assign(:changeset,
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(value, socket.assigns.records |> Enum.find(fn record -> record.id == id end))
    )
    |> (&{:noreply, &1}).()
  end

  defp nomination_has_vote?(changeset, nomination) do
    priorities() |> Enum.filter(fn {key, _} -> changeset.changes[key] end) |> Enum.any?(fn {key, _} -> changeset.changes[key].data == nomination end)
  end

  defp priority_unused?(changeset, priority) do
    changeset.changes[priority] == nil
  end

  defp priority_used?(changeset, priority) do
    changeset.changes[priority]
  end

  defp picked?(changeset, priority, nomination) do
    priority_used?(changeset, priority) && changeset.changes[priority].data == nomination
  end

  defp priorities(), do: [
    {:primary_nomination, "Primary"},
    {:secondary_nomination, "Secondary"},
    {:tertiary_nomination, "Tertiary"},
  ]

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any) => any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h1>Votes for <.link href={~p"/halls/#{@hall.id}"}><%= Pretty.get(@hall, :name) %></.link></h1>
    <div class="mt-3 mb-3 row row-cols-1 row-cols-md-3 g-4">
      <.render_vote :if={@changeset.changes[:primary_nomination]} key="primary_nomination" nomination={@changeset.changes.primary_nomination.data} />
      <.render_vote :if={@changeset.changes[:secondary_nomination]} key="secondary_nomination" nomination={@changeset.changes.secondary_nomination.data} />
      <.render_vote :if={@changeset.changes[:tertiary_nomination]} key="tertiary_nomination" nomination={@changeset.changes.tertiary_nomination.data} />
    </div>
    <div :if={length(@records) > 0} class="mt-3 mb-3 row row-cols-1 row-cols-md-4 g-4">
      <div :if={!nomination_has_vote?(@changeset, record)} :for={record <- @records} class="col">
        <div disabled class="card">
          <div class="card-header text-center">
            <h6><strong><%= record.name %></strong></h6>
          </div>
          <div class="card-body text-center">
            <div class="row gx-3">
              <div :for={{key, label} <- priorities()} class="col">
                <.button
                  :if={priority_unused?(@changeset, key)}
                  phx-click="pick_priority"
                  phx-value-id={record.id}
                  value={key}
                  usable_icon="check-to-slot"
                  class="btn-sm"
                  type="button"><%= label %></.button>
              </div>
            </div>
          </div>
          <img src={record.box_art_url} class="card-img-bottom" alt="The box art for the game">
        </div>
      </div>
    </div>
    """
  end

  attr :nomination, Core.Content.Nomination, required: true
  attr :key, :atom, required: true

  defp render_vote(assigns) do
    ~H"""
    <div class="col">
      <div disabled class="card">
        <div class="card-header text-center">
          <h6><strong><%= @nomination.name %></strong></h6>
        </div>
        <div class="card-body text-center">
          <.button
            phx-click="unpick_priority"
            phx-value-id={@nomination.id}
            value={@key}
            as="outline-danger"
            usable_icon="xmark"
            type="button">Reset</.button>
        </div>
        <img src={@nomination.box_art_url} class="card-img-bottom" alt="The box art for the game">
      </div>
    </div>
    """
  end
end