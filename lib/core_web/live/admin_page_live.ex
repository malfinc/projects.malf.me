defmodule CoreWeb.AdminPageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :refresh, 5000)

    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :dashboard, _params) do
    socket
    |> assign(:page_title, "Admin")
  end

  @impl true
  def handle_event(
        "award_points",
        _params,
        %{assigns: %{current_account: current_account}} = socket
      ) do
    Core.Gameplay.create_coin_transaction(%{
      account: current_account,
      value: 1000.0,
      reason: "because"
    })
    |> case do
      {:ok, _record} ->
        socket
        |> put_flash(:info, "Points awarded.")

      {:error, changeset} ->
        socket
        |> assign(:changeset, changeset)
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_info(:refresh, %{assigns: %{live_action: :dashboard}} = socket) do
    Process.send_after(self(), :refresh, 5000)
    {:noreply, push_patch(socket, to: "/admin", replace: true)}
  end

  @impl true
  def handle_info(:refresh, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(%{live_action: :dashboard} = assigns) do
    ~H"""
    <p>
      The administrative dashboard.
    </p>
    <.button class="btn-primary" phx-click="award_points" usable_icon="coin">Give me 1000 Coin</.button>
    <.link
      class="btn btn-primary"
      href={
        ~p"/auth/twitch?scope=user:read:email bits:read channel:read:redemptions channel:read:subscriptions"
      }
    >
      <.icon as="fa-twitch" /> Reauthenticate via Twitch
    </.link>
    """
  end
end
