defmodule CoreWeb.GameplayComponents do
  @moduledoc false
  use Phoenix.Component
  use CoreWeb, :verified_routes

  attr :pack, Core.Gameplay.Pack
  attr :rest, :global

  def pack(assigns) do
    ~H"""
    <div phx-hook="UnopenedCardPack" id={@pack.id} class="CardPack--isDraggable animate__animated" style="display: inline-block;" phx-click="open_pack" phx-value-id={@pack.id}>
      <img src={~p"/images/unopened_pack.png"} />
      <section>
        <CoreWeb.CoreComponents.tag>Season <%= @pack.season.position %></CoreWeb.CoreComponents.tag>
      </section>
    </div>
    """
  end

  attr :champion, Core.Gameplay.Champion
  attr :winner, :boolean, default: nil
  attr :width, :integer, default: 512
  attr :height, :integer, default: 768
  attr :rest, :global

  def champion(assigns) do
    ~H"""
    <div
      id={@champion.id}
      phx-hook="Card"
      data-tilt-glare
      class={[
        "champion",
        if(@winner, do: "champion--winner")
      ]}
      style={"background-image: url(#{~p"/images/rainbow_frame.png"}); width: #{@width + (15 * 2)}px; height: #{@height + (15 * 2)}px;"}
    >
      <div>
        <img src={@champion.image_uri} width={"#{@width}px"} height={"#{@height}px"} style="border-radius: 12px; position: absolute;" />

        <header style="position: relative; padding: 15px; ">
          <h4 style="text-shadow: 1px 1px 5px rgb(221, 160, 220);"><%= @champion.name %></h4>
          <h6 style="text-shadow: 1px 1px 5px rgb(221, 160, 220);">
            <em><%= @champion.plant.name %></em>
          </h6>
        </header>

        <div style="position: relative; display: grid; grid-template-rows: 1fr; justify-items: end; row-gap: 15px; margin-top: 45%;">
          <.circle>
            <CoreWeb.CoreComponents.icon :for={icon <- evolution_markers(@champion.upgrades)} as={icon} />
          </.circle>
        </div>

        <footer style="position: relative; display: grid; grid-template-columns: repeat(5, 1fr); justify-items: center; margin-top: 40%;">
          <.circle :for={{name, value} <- total_attributes(@champion)}>
            <div><%= value %></div>
            <div style="padding: 3px; border-radius: 5px; background-color: rgba(250, 250, 250, 0.85); color: black;">
              <%= slab(name) %>
            </div>
          </.circle>
        </footer>
      </div>
    </div>
    """
  end

  attr :card, Core.Gameplay.Card
  attr :width, :integer, default: 512
  attr :height, :integer, default: 768
  attr :rest, :global

  def battle_card(assigns) do
    ~H"""
    <div id={@card.champion.id} phx-hook="Card" data-tilt-glare style={"background-image: url(#{~p"/images/rainbow_frame.png"}); padding: 15px; width: #{@width + (15 * 2)}px; height: #{@height + (15 * 2)}px; border-radius: 12px; color: white; margin-left: auto; margin-right: auto; box-shadow: 2px 2px 9px 0px rgba(0,0,0,0.5);"}>
      <div>
        <img src={@card.champion.image_uri} width={"#{@width}px"} height={"#{@height}px"} style="border-radius: 12px; position: absolute;" />

        <header style="position: relative; padding: 15px; ">
          <h4 style="text-shadow: 1px 1px 5px rgb(221, 160, 220);"><%= @card.champion.name %></h4>
          <h6 style="text-shadow: 1px 1px 5px rgb(221, 160, 220);">
            <em><%= @card.champion.plant.name %></em>
          </h6>
          <%= if @card.holographic do %>
            HOLOGRAPHIC
          <% end %>
          <%= if @card.full_art do %>
            FULLART
          <% end %>
        </header>

        <div style="position: relative; display: grid; grid-template-rows: 1fr; justify-items: end; row-gap: 15px; margin-top: 45%;">
          <.circle>
            <CoreWeb.CoreComponents.icon :for={icon <- evolution_markers(@card.champion.upgrades)} as={icon} />
          </.circle>
          <.circle>
            <CoreWeb.CoreComponents.icon as="fa-pepper-hot fa-2x" style={"color: #{@card.rarity.color};"} />
          </.circle>
        </div>

        <footer style="position: relative; display: grid; grid-template-columns: repeat(5, 1fr); justify-items: center; margin-top: 40%;">
          <.circle :for={{name, value} <- total_attributes(@card.champion)}>
            <div><%= value %></div>
            <div style="padding: 3px; border-radius: 5px; background-color: rgba(250, 250, 250, 0.85); color: black;">
              <%= slab(name) %>
            </div>
          </.circle>
        </footer>
      </div>
    </div>
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
