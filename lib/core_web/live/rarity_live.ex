defmodule CoreWeb.RarityLive do
  @moduledoc false
  use CoreWeb, :live_view

  defp list_records(_assigns, _params) do
    Core.Gameplay.list_rarities()
    |> Enum.sort_by(&Map.get(&1, :season_pick_rate), :desc)
  end

  defp get_record(id) when is_binary(id) do
    Core.Gameplay.Rarity
    |> Core.Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
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
    |> assign(:page_title, "Rarities")
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
        |> assign(:changeset, Core.Gameplay.Rarity.changeset(record, %{}))
        |> assign(:page_title, "Rarity / #{record.name}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "update_rarity",
        %{"rarity" => attributes},
        %{assigns: %{record: record}} = socket
      ) do
    Core.Gameplay.update_rarity(record, attributes)
    |> case do
      {:ok, record} ->
        socket
        |> put_flash(:info, "Saved changes!")
        |> push_patch(to: ~p"/admin/rarities/#{record.id}")

      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
        |> put_flash(:error, "Something went wrong")
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any) => any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h2>Rarities <%= length(@records) %></h2>

    <table class="table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Color</th>
          <th>Season Pick Rate</th>
          <th>Cards Per Slot</th>
          <th>Holographic Rate</th>
          <th>Full Art Rate</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <%= for rarity <- @records do %>
          <tr>
            <td>
              <.link href={~p"/admin/rarities/#{rarity.id}"}>
                <%= rarity.id %>
              </.link>
            </td>
            <td>
              <%= rarity.name %>
            </td>
            <td>
              <%= rarity.color %>
            </td>
            <td>
              <%= rarity.season_pick_rate %>
            </td>
            <td>
              <%= rarity.pack_slot_caps
              |> Enum.with_index()
              |> Enum.map(fn {count, slot} -> "Slot #{slot + 1}: #{count}" end)
              |> Utilities.List.to_sentence() %>
            </td>
            <td>
              <%= rarity.holographic_rate %>
            </td>
            <td>
              <%= rarity.full_art_rate %>
            </td>
            <td></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h2>Rarity / <%= @record.name %></h2>
    <.simple_form :let={f} for={@changeset} id="edit_rarity" phx-submit="update_rarity">
      <.input label="Name" field={{f, :name}} type="text" />

      <.input label="Color" field={{f, :color}} type="text" />

      <.input
        label="Season Pick Rate"
        field={{f, :season_pick_rate}}
        type="number"
        details="How many cards of this rarity will be generated per season."
      />

      <.input label="Holographic Rate" field={{f, :holographic_rate}} type="number" />

      <.input
        label="Full Art Rate"
        field={{f, :full_art_rate}}
        type="number"
        details="Remember that this rate is a percentage of the Holographic Rate."
      />

      <:actions>
        <.button phx-disable-with="Saving..." type="submit" class="btn btn-primary">
          Save Changes
        </.button>
      </:actions>
    </.simple_form>
    """
  end
end
