defmodule CoreWeb.OrganizationLive do
  @moduledoc false
  use CoreWeb, :live_view

  defp list_records(_assigns, _params) do
    Core.Users.list_organizations()
    |> Core.Repo.preload([])
  end

  defp get_record(id) when is_binary(id) do
    Core.Users.get_organization(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([:accounts])
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
    |> assign(:page_title, "Organizations")
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
        |> assign(:page_title, "Organization / #{Pretty.get(record, :name)}")
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <h2>Organizations</h2>
    <table class="table">
      <tr>
        <th>Name</th>
        <th>Updated</th>
        <th>Links</th>
      </tr>
      <tr :for={organization <- @records}>
        <td>
          <%= Pretty.get(organization, :name) %>
        </td>
        <td>
          <%= timestamp_in_words_ago(organization) %>
        </td>
        <td>
          <.link href={~p"/admin/organizations/#{organization.id}"}>
            Show
          </.link>
        </td>
      </tr>
    </table>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h2>
      <%= Pretty.get(@record, :name) %>
    </h2>

    <h3 id="accounts">Accounts</h3>
    <ul>
      <li :for={account <- @record.accounts}>
        <.link href={~p"/admin/accounts/#{account.id}"}><%= account.username %></.link>
      </li>
    </ul>
    """
  end
end
