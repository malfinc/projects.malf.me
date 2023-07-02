defmodule CoreWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import CoreWeb.Gettext
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"
  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def tag(assigns) do
    ~H"""
    <span {@rest} class="badge bg-secondary"><%= render_slot(@inner_block) %></span>
    """
  end

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
  attr :as, :string, default: "primary"
  attr :state, :string, default: "usable"
  attr :rejection_icon, :string, default: "warning"
  attr :busy_icon, :string, default: "clock"
  attr :failure_icon, :string, default: "bug"
  attr :successful_icon, :string, default: "check"
  attr :usable_icon, :string, default: "busy"
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(disabled form name value)
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button :if={@state == "rejection"} class={"btn btn-danger-outline #{@class}"} {@rest}><.icon as={@rejection_icon} /><%= render_slot(@inner_block) %> Rejected</button>
    <button :if={@state == "failure"} class={"btn btn-danger #{@class}"} {@rest}><.icon as={@failure_icon} /><%= render_slot(@inner_block) %> Failed</button>
    <button :if={@state == "successful"} class={"btn btn-success #{@class}"} {@rest}><.icon as={@successful_icon} /><%= render_slot(@inner_block) %> Successful</button>
    <button :if={@state == "busy"} class={"btn btn-#{@as} #{@class}"} {@rest}><.icon as={@busy_icon} modifiers="fa-circle-notch fa-spin fa-fade" />Busy...</button>
    <button :if={@state == "usable"} class={"btn btn-#{@as} #{@class}"} {@rest}><.icon as={@usable_icon} /><%= render_slot(@inner_block) %></button>
    """
  end

  attr :type, :string, default: "solid"
  attr :as, :string, required: true
  attr :modifiers, :string, default: "busy"
  attr :rest, :global, include: ~w(disabled form name value class)

  def icon(assigns) do
    ~H"""
    <i class={"fa-#{@type} fa-#{@as} #{@modifiers}"} {@rest}></i>
    """
  end
end
