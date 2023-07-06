defmodule CoreWeb.HallLive do
  @moduledoc false
  use CoreWeb, :live_view

  defp list_records(_assigns, _params) do
    Core.Content.list_halls()
    |> Core.Repo.preload([])
  end

  def count_records(_assigns, _params) do
    Core.Content.count_halls()
  end

  defp get_record(id) when is_binary(id) do
    Core.Content.get_hall(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([:nominations])
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
    |> assign(:page_title, "Halls")
    |> assign(:changeset, Core.Content.Hall.changeset(%Core.Content.Hall{}, %{}))
    |> assign(:records, list_records(socket.assigns, params))
    |> assign(:record_count, count_records(socket.assigns, params))
  end

  defp as(socket, :show, %{"id" => id}) when is_binary(id) do
    get_record(id)
    |> case do
      {:error, :not_found} ->
        raise CoreWeb.Exceptions.NotFoundException

      record ->
        socket
        |> assign(:record, record)
        |> assign(:page_title, "Hall / #{Pretty.get(record, :name)}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("create_hall", params, socket) do
    params
    |> Core.Content.create_hall()
    |> case do
      {:ok, record} ->
        socket
        |> put_flash(:info, "Hall #{Pretty.get(record, :name)} created")
        |> redirect(to: ~p"/halls/halls")

      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
    end
    |> (&{:noreply, &1}).()
  end
  def handle_event("open_voting", _params, socket) do
    socket.assigns.record
    |> Ecto.Changeset.change(%{state: "voting"})
    |> Core.Repo.update()
    |> case do
      {:ok, record} ->
        socket
        |> put_flash(:info, "#{Pretty.get(record, :name)} now open for voting")
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any) => any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <%= if Core.Users.has_permission?(@current_account, "global", "administrator") do %>
      <h1>New Hall  </h1>
      <.simple_form :let={f} for={@changeset} id="new_hall" phx-submit="create_hall" class="mb-3">
        <div class="row">
          <div class="col">
            <.input field={{f, :name}} name="name" id="name" type="text" label="Name" required />
          </div>
          <div class="col">
            <.input field={{f, :deadline_at}} name="deadline_at" id="deadline_at" type="text" label="Deadline" required />
          </div>
          <div class="col">
            <.input field={{f, :category}} name="category" id="category" type="text" label="Category" required />
          </div>
        </div>
        <:actions>
          <.button phx-disable-with="Creating..." type="submit" class="btn btn-primary" usable_icon="plus">
            Create Hall
          </.button>
        </:actions>
      </.simple_form>
    <% end %>
    <h1>Halls</h1>

    <%= if @record_count > 0 do %>
      <ul>
        <%= for hall <- @records do %>
          <li>
            <.link href={~p"/halls/#{hall.id}"}>
              <%= Pretty.get(hall, :name) %>
            </.link>
          </li>
        <% end %>
      </ul>
    <% else %>
      <p>
        No halls setup yet.
      </p>
    <% end %>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1><%= Pretty.get(@record, :name) %></h1>

    <ul class="mt-3">
      <li :if={@record.state == "nominating"}><.link href={~p"/halls/#{@record.id}/nominations"}>Nominations</.link> (<%= length(@record.nominations) %>)</li>
      <li :if={@record.state == "voting"}><.link href={"/halls/#{@record.id}/votes"}>Votes</.link></li>
      <li :if={@record.state == "closed"}><.link href={"/halls/#{@record.id}/results"}>Results</.link></li>
    </ul>

    <div :if={Core.Users.has_permission?(@current_account, "global", "administrator")} class="mt-3">
      <.button :if={@record.state == "nominating"} usable_icon="person-booth" phx-click="open_voting">
        Open Voting
      </.button>
    </div>
    """
  end
end
