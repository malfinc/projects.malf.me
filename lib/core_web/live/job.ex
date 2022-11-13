defmodule CoreWeb.Live.Job do
  @moduledoc false
  use CoreWeb, :live_view
  import Ecto.Query

  on_mount({CoreWeb, :require_administrative_privilages})

  # "available" "scheduled" "executing" "retryable" "completed" "discarded"
  defp list_records(_assigns, params) do
    where =
      params
      |> Utilities.Map.atomize_keys()
      |> Keyword.new()

    from(
      Oban.Job,
      where: ^where,
      order_by: [desc: :inserted_at]
    )
    |> Core.Repo.all()
  end

  defp get_record(id) when is_binary(id) do
    Oban.Job
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
    |> assign(:admin_namespace, true)
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    socket
    |> assign(:page_title, "Jobs")
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
        |> assign(:page_title, "Job / #{record.id}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> Utilities.Tuple.result(:noreply)
  end

  @impl true
  def handle_event("retry_all", _params, socket) do
    Oban.retry_all_jobs(Oban.Job)
    |> case do
      {:ok, count} ->
        socket
        |> put_flash(:info, "Retrying #{count} jobs")
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("cancel_all", _params, socket) do
    Oban.cancel_all_jobs(Oban.Job)
    |> case do
      {:ok, count} ->
        socket
        |> put_flash(:info, "Killed #{count} jobs")
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("retry", %{"id" => id}, socket) do
    Oban.retry_job(String.to_integer(id))

    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("cancel", %{"id" => id}, socket) do
    Oban.cancel_job(String.to_integer(id))

    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{live_action: :list | :show}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h2>Jobs</h2>

    <h3 id="actions">Actions</h3>
    <section>
      <button type="button" phx-click="retry_all" class="btn btn-outline-warning">Retry All</button>
      <button type="button" phx-click="cancel_all" class="btn btn-outline-danger">Cancel All</button>
    </section>

    <table class="table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Worker</th>
          <th>State</th>
          <th>Queue</th>
          <th>Node</th>
          <th>Attempts</th>
          <th>Started</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <%= for job <- @records do %>
          <tr>
            <td>
              <%= link to: Routes.admin_job_path(@socket, :show, job.id) do %>
                #<%= job.id %>
              <% end %>
            </td>
            <td><%= job.worker %></td>
            <td><%= job.state %></td>
            <td><%= job.queue %></td>
            <td><%= Utilities.List.to_sentence(job.attempted_by || []) %></td>
            <td><%= job.attempt %>/<%= job.max_attempts %></td>
            <td><time datetime={job.inserted_at}><%= Timex.from_now(job.inserted_at) %></time></td>
            <td>
              <section>
                <button type="button" phx-click="retry" phx-value-id={job.id} class="btn btn-outline-warning">Retry</button>
                <button type="button" phx-click="cancel" phx-value-id={job.id} class="btn btn-outline-danger">Cancel</button>
              </section>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h2>Job / <%= @record.worker %> #<%= @record.id %></h2>
    <p>
      <%= @record.queue %> queue -
      currently <%= @record.state %> -
      <%= if @record.attempted_at do %><%= @record.attempt %> of <%= @record.max_attempts %> (last attempt <time title={@record.attempted_at} datetime={@record.attempted_at}><%= Timex.from_now(@record.attempted_at) %></time>)<% else %>never attempted<% end %>
    </p>

    <h4 id="arguments">Arguments</h4>
    <p>
      <code class="inline"><%= code_as_html(@record.args) %></code>
    </p>

    <%= if @record.attempted_by do %>
      <h4 id="attempted">Attempted By</h4>
      <ul>
        <%= for node <- @record.attempted_by do %>
          <li><%= node %></li>
        <% end %>
      </ul>
    <% end %>

    <h4 id="errors">Errors</h4>
    <dl>
      <%= for error <- Enum.reverse(@record.errors) do %>
        <dt><time title={error["at"]} datetime={error["at"]}><%= error_at_ago(error) %></time></dt>
        <dd><%= error["error"] |> (&"```\n#{&1}\n```").() |> Earmark.as_html!() |> raw() %></dd>
      <% end %>
    </dl>

    <h4 id="timestamps">Timestamps</h4>
    <dl>
      <dt>Started At</dt>
      <dd><time title={@record.inserted_at} datetime={@record.inserted_at}><%= Timex.from_now(@record.inserted_at) %></time></dd>
      <%= if @record.cancelled_at do %>
        <dt>Cancelled At</dt>
        <dd><time title={@record.cancelled_at} datetime={@record.cancelled_at}><%= Timex.from_now(@record.cancelled_at) %></time></dd>
      <% end %>
      <%= if @record.discarded_at do %>
        <dt>Discarded At</dt>
        <dd><time title={@record.discarded_at} datetime={@record.discarded_at}><%= Timex.from_now(@record.discarded_at) %></time></dd>
      <% end %>
      <%= if @record.completed_at do %>
        <dt>Completed At</dt>
        <dd><time title={@record.completed_at} datetime={@record.completed_at}><%= Timex.from_now(@record.completed_at) %></time></dd>
      <% end %>
    </dl>
    """
  end
end
