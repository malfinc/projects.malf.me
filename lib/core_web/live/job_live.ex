defmodule CoreWeb.JobLive do
  @moduledoc false
  import Ecto.Query
  use CoreWeb, :live_view

  defp default_states(),
    do: [
      "available",
      "scheduled",
      "executing",
      "retryable",
      "completed",
      "discarded"
    ]

  defp list_records(_assigns, _params) do
    from(
      job in Oban.Job,
      where: job.state in ^(default_states() -- ["completed"]),
      # ,
      order_by: [desc: :inserted_at]
      # limit: 25
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
    if connected?(socket), do: Process.send_after(self(), :refresh, 5000)

    socket
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
  def handle_info(:refresh, %{assigns: %{live_action: :list}} = socket) do
    Process.send_after(self(), :refresh, 5000)

    socket
    |> push_patch(to: "/admin/jobs", replace: true)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_info(:refresh, %{assigns: %{live_action: :show, record: %{id: id}}} = socket) do
    Process.send_after(self(), :refresh, 5000)

    socket
    |> push_patch(to: "/admin/jobs/#{id}", replace: true)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_info(:refresh, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("resume_default_queue", _params, socket) do
    Oban.resume_queue(queue: :default)
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Resuming default queue")
        |> push_patch(to: "/admin/jobs", replace: true)
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("pause_default_queue", _params, socket) do
    Oban.pause_queue(queue: :default)
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Pausing default queue")
        |> push_patch(to: "/admin/jobs", replace: true)
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("retry_all", _params, socket) do
    Oban.retry_all_jobs(Oban.Job)
    |> case do
      {:ok, count} ->
        socket
        |> put_flash(:info, "Retrying #{count} jobs")
        |> push_patch(to: "/admin/jobs", replace: true)
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
        |> push_patch(to: "/admin/jobs", replace: true)
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("retry", %{"id" => id}, socket) do
    Oban.retry_job(String.to_integer(id))

    socket
    |> push_patch(to: "/admin/jobs/#{id}", replace: true)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("cancel", %{"id" => id}, socket) do
    Oban.cancel_job(String.to_integer(id))

    socket
    |> push_patch(to: "/admin/jobs/#{id}", replace: true)
    |> (&{:noreply, &1}).()
  end

  defp count_by_queue(records) do
    records
    |> Enum.group_by(&Map.get(&1, :state))
    |> Enum.map(fn {state, list} -> "#{state}: #{length(list)}" end)
    |> Utilities.List.to_sentence()
  end

  @impl true
  @spec render(%{live_action: :list | :show}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h2>
      Jobs (<%= count_by_queue(@records) %>)
    </h2>

    <h3 id="actions">Actions</h3>
    <section>
      <%= if Oban.check_queue(queue: :default).paused do %>
        <button type="button" phx-click="resume_default_queue" class="btn btn-outline-info">
          Resume Default Queue
        </button>
      <% else %>
        <button type="button" phx-click="pause_default_queue" class="btn btn-outline-info">
          Pause Default Queue
        </button>
      <% end %>
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
          <th>Data</th>
          <th>Attempts</th>
          <th>Started</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <%= for job <- @records do %>
          <tr>
            <td>
              <.link href={~p"/admin/jobs/#{job.id}"}>
                #<%= job.id %>
              </.link>
            </td>
            <td><%= job.worker %></td>
            <td><%= job.state %></td>
            <td><%= job.queue %></td>
            <td>
              <%= case job.worker do %>
                <% "Core.Job.GeneratePropertyJob" -> %>
                  <table class="table">
                    <thead>
                      <tr>
                        <th>Core.Randomizer</th>
                        <th>Property</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td><%= job.args["randomizer"] %></td>
                        <td><%= job.args["property"] %></td>
                      </tr>
                    </tbody>
                  </table>
              <% end %>
            </td>
            <td><%= job.attempt %>/<%= job.max_attempts %></td>
            <td><time datetime={job.inserted_at}><%= Timex.from_now(job.inserted_at) %></time></td>
            <td>
              <section>
                <button type="button" phx-click="retry" phx-value-id={job.id} class="btn btn-outline-warning">
                  Retry
                </button>
                <button type="button" phx-click="cancel" phx-value-id={job.id} class="btn btn-outline-danger">
                  Cancel
                </button>
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

    <h3 id="actions">Actions</h3>
    <section>
      <button type="button" phx-click="retry" phx-value-id={@record.id} class="btn btn-outline-warning">
        Retry
      </button>
      <button type="button" phx-click="cancel" phx-value-id={@record.id} class="btn btn-outline-danger">
        Cancel
      </button>
    </section>

    <p>
      <%= @record.queue %> queue -
      currently <%= @record.state %> -
      <%= if @record.attempted_at do %>
        <%= @record.attempt %> of <%= @record.max_attempts %> (last attempt <time title={@record.attempted_at} datetime={@record.attempted_at}><%= Timex.from_now(@record.attempted_at) %></time>)
      <% else %>
        never attempted
      <% end %>
    </p>

    <h3 id="arguments">Arguments</h3>
    <p>
      <code class="inline"><%= code_as_html(@record.args) %></code>
    </p>

    <%= if @record.attempted_by do %>
      <h3 id="attempted">Attempted By</h3>
      <ul>
        <%= for node <- @record.attempted_by do %>
          <li><%= node %></li>
        <% end %>
      </ul>
    <% end %>

    <h3 id="errors">Errors</h3>
    <dl>
      <%= for error <- Enum.reverse(@record.errors) do %>
        <dt><time title={error["at"]} datetime={error["at"]}><%= error_at_ago(error) %></time></dt>
        <dd><%= error["error"] |> (&"```\n#{&1}\n```").() |> Earmark.as_html!() |> raw() %></dd>
      <% end %>
    </dl>

    <h3 id="timestamps">Timestamps</h3>
    <dl>
      <dt>Started At</dt>
      <dd>
        <time title={@record.inserted_at} datetime={@record.inserted_at}>
          <%= Timex.from_now(@record.inserted_at) %>
        </time>
      </dd>
      <%= if @record.cancelled_at do %>
        <dt>Cancelled At</dt>
        <dd>
          <time title={@record.cancelled_at} datetime={@record.cancelled_at}>
            <%= Timex.from_now(@record.cancelled_at) %>
          </time>
        </dd>
      <% end %>
      <%= if @record.discarded_at do %>
        <dt>Discarded At</dt>
        <dd>
          <time title={@record.discarded_at} datetime={@record.discarded_at}>
            <%= Timex.from_now(@record.discarded_at) %>
          </time>
        </dd>
      <% end %>
      <%= if @record.completed_at do %>
        <dt>Completed At</dt>
        <dd>
          <time title={@record.completed_at} datetime={@record.completed_at}>
            <%= Timex.from_now(@record.completed_at) %>
          </time>
        </dd>
      <% end %>
    </dl>
    """
  end
end
