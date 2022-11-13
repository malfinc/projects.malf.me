defmodule CoreWeb.Live.Account do
  @moduledoc false
  use CoreWeb, :live_view

  on_mount({CoreWeb, :require_administrative_privilages})

  defp list_records(_assigns, _params) do
    Core.Users.list_accounts()
    |> Core.Repo.preload([])
    |> Core.Decorate.deep()
  end

  defp get_record(id) when is_binary(id) do
    Core.Users.get_account(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload(organization_memberships: [:organization, :permissions])
        |> Core.Decorate.deep()
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
    |> assign(:page_title, "Accounts")
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
        |> assign(:page_title, "Account / #{record.email_address}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> Utilities.Tuple.result(:noreply)
  end

  @impl true
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h2>Accounts</h2>
    <table class="table">
      <tr>
        <th>Email Address</th>
        <th>Username</th>
        <th>Updated</th>
        <th>Links</th>
      </tr>
      <%= for account <- @records do %>
        <tr>
          <td>
            <i class="fa-solid fa-envelope"></i>
            <a href={"mailto:#{account.email_address}"}>
              <%= account.email_address %>
            </a>
          </td>
          <td>
            <%= account.username %>
          </td>
          <td>
            <%= account.updated_at %>
          </td>
          <td>
            <%= link to: Routes.admin_account_path(@socket, :show, account.id) do %>
              Show
            <% end %>
          </td>
        </tr>
      <% end %>
    </table>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h2>
      <%= @record.username %>
    </h2>

    <div style="display: grid; gap: 10px; grid-template-columns: 1fr 1fr 1fr;">
      <div style="padding: 15px; border: 1px solid var(--highlight-color);">
        <strong>Email</strong>
        <p>
          <a href={"mailto:#{@record.email_address}"}><%= @record.email_address %></a>
        </p>
      </div>
      <div style="padding: 15px; border: 1px solid var(--highlight-color);">
        <strong>Organizations</strong>
        <ul>
          <%= for organization_membership <- @record.organization_memberships do %>
            <li>
              <%= link to: Routes.admin_organization_path(@socket, :show, organization_membership.organization.id) do %>
                <%= organization_membership.organization.name %>
              <% end %>
              (<%= organization_membership.permissions
              |> Utilities.List.pluck(:name)
              |> Utilities.List.to_sentence() %>)
            </li>
          <% end %>
        </ul>
      </div>

      <div style="padding: 15px; border: 1px solid var(--highlight-color);">
        <strong>Onboarding State</strong>
        <p>
          <%= @record.onboarding_state %>
        </p>
      </div>

      <div style="padding: 15px; border: 1px solid var(--highlight-color);">
        <strong>Confirmed At</strong>
        <p>
          <time time={@record.confirmed_at}><%= @record.confirmed_at %></time>
        </p>
      </div>

      <div style="padding: 15px; border: 1px solid var(--highlight-color);">
        <strong>Inserted At</strong>
        <p>
          <time time={@record.inserted_at}><%= @record.inserted_at %></time>
        </p>
      </div>

      <div style="padding: 15px; border: 1px solid var(--highlight-color);">
        <strong>Updated At</strong>
        <p>
          <time time={@record.updated_at}><%= @record.updated_at %></time>
        </p>
      </div>
    </div>
    """
  end
end
