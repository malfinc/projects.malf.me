defmodule CoreWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import CoreWeb.Gettext

  @doc """
  Renders flash notices.
  ## Examples
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :icon, :string, default: nil
  attr :context, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :close, :boolean, default: true, doc: "whether the flash can be closed"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      role="alert"
      class={[
        "alert d-flex align-items-center justify-content-between",
        @kind == :info && "alert-primary",
        @kind == :error && "alert-warning"
      ]}
      {@rest}
    >
      <h4 :if={@title} class="alert-heading">
        <i :if={@icon} class={"fa-solid fa-#{@icon}"} /> <%= @title %>
      </h4>

      <p><%= msg %></p>
      <hr :if={@context} />
      <p :if={@context} class="mb-0"><%= @context %></p>
      <.button :if={@close} class="btn-close" data-bs-dismiss="alert" aria-label="close"></.button>
    </div>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go">Send!</.button>
  """
  attr :type, :string, default: "button"
  attr :loading, :boolean, default: false
  attr :icon, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value class)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button {@rest} type={@type} disabled={assigns[:loading]}>
      <%= if assigns[:loading] do %>
        <i class="fa-solid fa-circle-notch fa-spin fa-fade"></i> Loading...
      <% else %>
        <i class={"fa-solid fa-#{assigns[:icon]}"}></i> <%= render_slot(@inner_block) %>
      <% end %>
    </button>
    """
  end

  ## JS Commands
  # def show(js \\ %JS{}, selector) do
  #   JS.show(js,
  #     to: selector,
  #     transition:
  #       {"transition-all transform ease-out duration-300",
  #        "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
  #        "opacity-100 translate-y-0 sm:scale-100"}
  #   )
  # end
end
