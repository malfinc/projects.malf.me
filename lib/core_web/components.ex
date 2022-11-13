defmodule CoreWeb.Components do
  @moduledoc """
  Shared Component module behavior
  """
  require Logger

  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML
  use Phoenix.Component

  @spec button(map()) :: Phoenix.LiveView.Rendered.t()
  def button(assigns) do
    ~H"""
    <button
      type="button"
      {assigns_to_attributes(assigns, [:loading, :icon])}
      disabled={assigns[:loading]}
    >
      <%= if assigns[:loading] do %>
        <i class="fa-solid fa-circle-notch fa-spin fa-fade"></i> Loading...
      <% else %>
        <i class={"fa-solid fa-#{assigns[:icon]}"}></i> <%= render_slot(@inner_block) %>
      <% end %>
    </button>
    """
  end

  @spec loading_text_indicator(%{size: pos_integer()}) ::
          Phoenix.LiveView.Rendered.t()
  def loading_text_indicator(assigns) do
    ~H"""
    <%= for number <- 1..@size do %>
      <i
        class="fa-solid fa-square-full fa-beat-fade"
        style={"--fa-animation-duration: 3s; --fa-fade-opacity: 0.2; --fa-animation-delay: #{number / 2.0}s"}
      >
      </i>
    <% end %>
    """
  end
end
