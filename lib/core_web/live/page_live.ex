defmodule CoreWeb.PageLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, %{transport_pid: nil} = socket),
    do:
      socket
      |> assign(:page_title, "Loading...")
      |> assign(:page_loading, true)
      |> (&{:ok, &1, layout: layout(socket.assigns)}).()

  def mount(_params, _session, socket),
    do:
      socket
      |> (&{:ok, &1, layout: layout(socket.assigns)}).()

  defp layout(%{live_action: :home}), do: {CoreWeb.Layouts, :content}
  defp layout(_), do: {CoreWeb.Layouts, :app}

  defp as(socket, :home, _params) do
    socket
    |> assign(:page_title, "Michael Al Fox")
  end

  defp as(socket, :faq, _params) do
    socket
    |> assign(:page_title, "Frequently Asked Questions")
  end

  defp as(socket, :projects, _params) do
    socket
    |> assign(:page_title, "Projects")
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

  def render(%{live_action: :projects} = assigns) do
    ~H"""
    <div class="row row-cols-1 row-cols-md-2 g-4">
      <div class="col">
        <div class="card">
          <img src={~p"/images/halls.png"} class="card-img-top" alt="A long impressive hallway lined with trophies, statues, and art" />
          <div class="card-body">
            <h5 class="card-title"><.link href={~p"/halls/"}>Halls</.link></h5>
            <p class="card-text">This is a longer card with supporting text below as a natural lead-in to additional content. This content is a little bit longer.</p>
          </div>
        </div>
      </div>
      <div class="col">
        <div class="card">
          <img src={~p"/images/aggroculture.png"} class="card-img-top" alt="A verdant grassland" />
          <div class="card-body">
            <h5 class="card-title"><.link href={~p"/lop/"}>Aggroculture</.link></h5>
            <p class="card-text">This is a longer card with supporting text below as a natural lead-in to additional content. This content is a little bit longer.</p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
