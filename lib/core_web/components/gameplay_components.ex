defmodule CoreWeb.GameplayComponents do
  @moduledoc false
  use Phoenix.Component
  use CoreWeb, :verified_routes

  attr :champion, Core.Gameplay.Champion
  attr :width, :integer, default: 512
  attr :height, :integer, default: 768
  attr :rest, :global

  def card(assigns) do
    ~H"""
    <section style={"background-image: linear-gradient(to right, darkblue, darkorchid); padding: 15px; width: #{@width + (15 * 2)}px; height: #{@height + (15 * 2)}px; border-radius: 12px; color: white;"}>
      <section>
        <img src={~p"/images/apocalypse_scorpion.png"} width={"#{@width}px"} height={"#{@height}px"} style="border-radius: 12px; position: absolute;" />
        <header style="position: relative; padding-top: 15px; padding-left: 15px;">
          <h2><%= @champion.name %></h2>
          <h5><%= @champion.plant.name %> <em><small>(<%= @champion.plant.species %>)</small></em></h5>
        </header>
        <section style="position: relative; display: grid; grid-template-rows: 1fr; justify-items: end; row-gap: 15px;">
          <.circle>
            <%= for icon <- evolution_markers(@champion.upgrades) do %>
              <i class={icon}></i>
            <% end %>
          </.circle>
          <.circle>
            <i class="fa-solid fa-pepper-hot fa-2x"></i>
          </.circle>
        </section>
        <footer style="position: relative; display: grid; grid-template-rows: repeat(5, 1fr);">
          <%= for {name, value} <- total_attributes(@champion) do %>
            <.circle>
              <section><%= value %></section>
              <section style="padding: 3px; border-radius: 5px; background-color: rgba(250, 250, 250, 0.85); color: black;"><%= slab(name) %></section>
            </.circle>
          <% end %>
        </footer>
      </section>
    </section>
    """
  end

  slot :inner_block
  def circle(assigns) do
    ~H"""
    <section style="display: flex; align-items: center; justify-content: space-evenly; border-radius: 50%; border: 2px solid darkorchid; width: 4.5rem; height: 4.5rem;">
      <%= render_slot(@inner_block) %>
    </section>
    """
  end

  defp total_evolution(upgrades) do
    Enum.reduce(upgrades, 2, fn %{stage: stage}, current_stage ->
      stage + current_stage
    end)
  end

  def evolution_markers(upgrades) do
    total_evolution(upgrades)
    |> Utilities.Enum.times(fn -> "fa-solid fa-circle" end)
    |> Enum.concat(["fa-regular fa-circle", "fa-regular fa-circle", "fa-regular fa-circle"])
    |> Enum.take(3)
  end

  defp total_attributes(%{upgrades: upgrades, plant: %{starting_attributes: starting_attributes}}) do
    Enum.reduce(upgrades, starting_attributes, fn upgrade, attributes ->
      Map.merge(attributes, Map.take(upgrade, Map.keys(attributes)))
    end)
  end
  defp slab("strength"), do: "STR"
  defp slab("endurance"), do: "END"
  defp slab("speed"), do: "SPD"
  defp slab("luck"), do: "LCK"
  defp slab("intelligence"), do: "INT"
end
