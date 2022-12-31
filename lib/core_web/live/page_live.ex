defmodule CoreWeb.PageLive do
  @moduledoc false
  use CoreWeb, [:live_view, :content]

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :home, _params) do
    socket
    |> assign(:page_title, "Michael Al Fox")
  end

  defp as(socket, :admin, _params) do
    socket
    |> assign(:page_title, "Admin")
  end

  defp as(socket, :faq, _params) do
    socket
    |> assign(:page_title, "Frequently Asked Questions")
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :home} = assigns) do
    ~H"""
    <dl>
      <dt>Twitter</dt>
      <dd>
        Lorem, ipsum dolor sit amet consectetur adipisicing elit. Harum aspernatur inventore corrupti officia beatae blanditiis pariatur maiores illo suscipit consequatur alias error aliquid, dolorum ad quisquam deserunt quia quaerat. Nesciunt.
      </dd>
      <dt>Twitch</dt>
      <dd>
        Lorem, ipsum dolor sit amet consectetur adipisicing elit. Harum aspernatur inventore corrupti officia beatae blanditiis pariatur maiores illo suscipit consequatur alias error aliquid, dolorum ad quisquam deserunt quia quaerat. Nesciunt.
      </dd>
      <dt>Youtube</dt>
      <dd>
        Lorem, ipsum dolor sit amet consectetur adipisicing elit. Harum aspernatur inventore corrupti officia beatae blanditiis pariatur maiores illo suscipit consequatur alias error aliquid, dolorum ad quisquam deserunt quia quaerat. Nesciunt.
      </dd>
      <dt>Instagram</dt>
      <dd>
        Lorem, ipsum dolor sit amet consectetur adipisicing elit. Harum aspernatur inventore corrupti officia beatae blanditiis pariatur maiores illo suscipit consequatur alias error aliquid, dolorum ad quisquam deserunt quia quaerat. Nesciunt.
      </dd>
    </dl>
    """
  end
end
