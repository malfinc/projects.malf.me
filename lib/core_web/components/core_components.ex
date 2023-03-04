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

  def flash(%{flash: %{"error" => error_messages}} = assigns) when is_list(error_messages) do
    ~H"""
    <.flash :for={error_message <- @flash["error"]} kind={:error}>
      <%= error_message %>
    </.flash>
    """
  end

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
        <.icon :if={@icon} class={"fa-#{@icon}"} /> <%= @title %>
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
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button {@rest} type={@type} disabled={assigns[:loading]} class={"btn #{@class}"}>
      <%= if assigns[:loading] do %>
        <.icon as="fa-circle-notch fa-spin fa-fade" /> Loading...
      <% else %>
        <.icon as={"fa-#{assigns[:icon]}"} /> <%= render_slot(@inner_block) %>
      <% end %>
    </button>
    """
  end

  attr :as, :string
  attr :type, :string, default: "fa-solid"
  attr :rest, :global, include: ~w(disabled form name value class)

  def icon(assigns) do
    ~H"""
    <i {@rest} class={"#{@type} #{@as}"}></i>
    """
  end
end
