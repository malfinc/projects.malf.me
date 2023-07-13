defmodule CoreWeb.HallLive do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  defp list_records(_assigns, _params, category) do
    Core.Content.list_halls(fn subquery ->
      from(subquery, where: [category: ^category], limit: 6, preload: [])
    end)
    |> Core.Repo.all()
  end

  def count_records(_assigns, _params, category) do
    Core.Content.list_halls(fn subquery ->
      from(subquery, where: [category: ^category], limit: 10, preload: [])
    end)
    |> Core.Repo.aggregate(:count)
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
    |> assign(:hundreds_records, list_records(socket.assigns, params, "hundred"))
    |> assign(:hundreds_record_count, count_records(socket.assigns, params, "hundred"))
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
      <h2>New Hall</h2>
      <.simple_form :let={f} for={@changeset} id="new_hall" phx-submit="create_hall" class="mb-3" data-bs-theme="light">
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
    <section class="py-5 container">
      <header class="mx-auto col-8">
        <h1 class="fw-light halls-title-big text-center">The Halls</h1>
        <p class="text-center lead">
          Welcome to The Halls! Each Hall is a way to categorize a specific play style for the various games I play.
          While it may seem a bit convoluted, this framework gives me focus and direction while streaming and allows viewers
          to know my intent with a given game's playthrough.
        </p>
      </header>
    </section>

    <section class="py-5 container">
      <div :if={@hundreds_record_count > 0} class="row g-3">
        <div :for={hall <- @hundreds_records} class="col-auto">
          <div :if={true} class="card text-bg-green shadow-sm" style="max-width: 200px;">
            <img src={~p"/images/unknown.jpg"} class="card-img-top" alt="Missing box art">
            <div class="card-header text-center">
              <h6>
                <strong>
                  <.link :if={hall.state == "nominating"} href={~p"/halls/#{hall.id}/nominations"}>
                    <%= Pretty.get(hall, :name) %>
                  </.link>
                  <.link :if={hall.state == "voting"} href={~p"/halls/#{hall.id}/votes"}>
                    <%= Pretty.get(hall, :name) %>
                  </.link>
                  <.link :if={hall.state == "started"} href={~p"/halls/#{hall.id}"}>
                    <%= Pretty.get(hall, :name) %>
                  </.link>
                </strong>
              </h6>
            </div>
            <div :if={hall.state == "nominating"} class="card-body text-center">
              Nominations are open!
            </div>
            <div :if={hall.state == "voting"} class="card-body text-center">
              Voting is open!
            </div>
            <div :if={hall.state == "started"} class="card-body text-center">
              details details
            </div>
          </div>
          <div :if={false} class="card text-bg-green shadow-sm" style="max-width: 200px;">
            <img src={hall.winner.external_box_art_url} class="card-img-top" alt="The box art for the game">
            <div class="card-header text-center">
              <h6>
                <strong>
                  <.link href={~p"/halls/#{hall.id}"}>
                    <%= hall.winner.name %>
                  </.link>
                </strong>
              </h6>
            </div>
            <div :if={hall.state == "nominating"} class="card-body text-center">
              Nominations are open!
            </div>
            <div :if={hall.state == "voting"} class="card-body text-center">
              Voting is open!
            </div>
            <div :if={hall.state == "started"} class="card-body text-center">
              details details
            </div>
          </div>
        </div>

        <div :if={@hundreds_record_count > 6} class="col-auto">
          <div class="card shadow-sm" style="max-width: 200px;">
            <div class="card-header text-center">
              <h6>
                <strong>+<%= @hundreds_record_count - 6 %> more</strong>
              </h6>
            </div>
          </div>
        </div>
      </div>
      <p :if={@hundreds_record_count == 0} class="text-center">
        No hall of hundreds yet.
      </p>
    </section>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h1><%= Pretty.get(@record, :name) %></h1>

    <ul class="mt-3">
      <li :if={@record.state == "nominating"}><.link href={~p"/halls/#{@record.id}/nominations"}>Nominations</.link> (<%= length(@record.nominations) %>)</li>
      <li :if={@record.state == "voting"}><.link href={"/halls/#{@record.id}/votes"}>Votes</.link></li>
      <li :if={@record.state == "started"}><.link href={"/halls/#{@record.id}/results"}>Results</.link></li>
    </ul>

    <div :if={Core.Users.has_permission?(@current_account, "global", "administrator")} class="mt-3">
      <.button :if={@record.state == "nominating"} usable_icon="person-booth" phx-click="open_voting">
        Open Voting
      </.button>
    </div>
    """
  end
end
