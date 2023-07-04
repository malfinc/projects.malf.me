defmodule CoreWeb.ContentComponents do
  @moduledoc """
  Provides content UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import CoreWeb.Gettext

  @doc """
  Renders the sidebar
  """
  def sidebar(assigns) do
    ~H"""
    <aside>
      <section>
        <div>
          <h2><span>Community</span></h2>
          <ul>
            <li>
              <.link href="#">Community Cookbook</.link>
            </li>
            <li>
              <.link href="/ac">AggroCulture</.link>
            </li>
            <li>
              <.link href="#">Towers of Bebylon</.link>
            </li>
          </ul>
        </div>
      </section>
      <section>
        <div>
          <h2><span>Latet Blog post</span></h2>
          <p>
            Lorem ipsum, dolor sit amet consectetur adipisicing elit. Quo, earum ducimus facilis quisquam quos nostrum nemo quibusdam provident debitis. Totam necessitatibus explicabo cumque mollitia tenetur nobis cupiditate quia commodi voluptate?
          </p>
        </div>
      </section>
      <section>
        <div>
          <h2><span>Twitch Schedule</span></h2>
          <p>
            Lorem ipsum dolor sit amet consectetur adipisicing elit. Accusantium obcaecati fugit, laborum facilis consequuntur officiis dignissimos incidunt velit veritatis porro mollitia, id ab beatae sint sit ad optio? Iusto, corporis.
          </p>
        </div>
      </section>
      <section id="social-links">
        <ul>
          <li>
            <.link href="https://www.twitch.tv/michaelalfox">
              <img
                src={~p"/images/sidebar-social-twitch.png"}
                alt="The twitch logo"
                width="36px"
                height="36px"
              />
            </.link>
          </li>
          <li>
            <.link href="https://youtube.com/michaelalfox">
              <img
                src={~p"/images/sidebar-social-youtube.png"}
                alt="The youtube logo"
                width="36px"
                height="36px"
              />
            </.link>
          </li>
          <li>
            <.link href="https://twitter.com/michaelalfox">
              <img
                src={~p"/images/sidebar-social-twitter.png"}
                alt="The twitter logo"
                width="36px"
                height="36px"
              />
            </.link>
          </li>
          <li>
            <.link href="https://www.instagram.com/michaelalfox/">
              <img
                src={~p"/images/sidebar-social-instagram.png"}
                alt="The instagram logo"
                width="36px"
                height="36px"
              />
            </.link>
          </li>
        </ul>
        <p>
          &copy; <%= DateTime.utc_now().year %> Michael Fox · Built by
          <.link href="#">@th3mcnuggetz</.link>,
          <.link href="https://twitter.com/krainboltgreene">@krainboltgreene</.link>
        </p>
      </section>
    </aside>
    """
  end

  @doc """
  Renders the site header
  """
  attr :current_account, Core.Users.Account, default: nil
  attr :namespace, :string

  def site_header(assigns) do
    ~H"""
    <nav class="navbar navbar-expand-lg navbar-dark  bg-dark ">
      <section class="container-fluid">
        <.link href={~p"/"} class="navbar-brand">
          <img
            src={~p"/images/banner-logo.svg"}
            alt="the malf logo, which is two triangles arranged in a way that makes a cute fox head with ears"
            title="the malf logo, which is two triangles arranged in a way that makes a cute fox head with ears"
          />
        </.link>
        <button
          class="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarSupportedContent"
          aria-controls="navbarSupportedContent"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span class="navbar-toggler-icon" />
        </button>

        <section class="collapse navbar-collapse" id="navbarSupportedContent">
          <ul class="navbar-nav me-auto mb-2 mb-lg-0">
            <li class="nav-item">
              <.link href="https://www.twitch.tv/michaelalfox" class="nav-link">Watch Now</.link>
            </li>
            <li class="nav-item">
              <.link href="#blog_link_here" class="nav-link">Blog</.link>
            </li>
            <li class="nav-item">
              <.link href={~p"/socials"} class="nav-link">
                Socials
              </.link>
            </li>
            <li class="nav-item">
              <.link href={~p"/discord"} class="nav-link">
                Discord
              </.link>
            </li>
            <li class="nav-item">
              <.link href={~p"/about"} class="nav-link">
                About
              </.link>
            </li>
            <li class="nav-item">
              <.link href={~p"/projects"} class="nav-link">
                Projects
              </.link>
            </li>
            <li class="nav-item">
              <.link href={~p"/contact"} class="nav-link">
                Contact
              </.link>
            </li>
            <li :if={@namespace == "halls"} :for={{path, name} <- hall_links()} class="nav-item">
              <.link href={path} class="nav-link">
                <%= name %>
              </.link>
            </li>
            <li :if={@namespace == "lop"} :for={{path, name} <- aggroculture_links()} class="nav-item">
              <.link href={path} class="nav-link">
                <%= name %>
              </.link>
            </li>

            <li :if={@current_account && Core.Users.has_permission?(@current_account, "global", "administrator")} class="nav-item">
              <.link href={~p"/admin"} class="nav-link">
                Admin
              </.link>
            </li>

            <li :if={@current_account && @namespace == "admin"} :for={{path, name} <- admin_links()} class="nav-item">
              <.link href={path} class="nav-link">
                <%= name %>
              </.link>
            </li>
          </ul>

          <ul class="navbar-nav me-right mb-2 mb-lg-0">
            <%= if @current_account do %>
              <li class="nav-item">
                <%= @current_account.email_address %>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/settings"} class="nav-link">Account</.link>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/log_out"} method="delete" class="nav-link">Log out</.link>
              </li>
            <% else %>
              <li class="nav-item">
                <.link href={~p"/auth/twitch"} class="nav-link">Authenticate via Twitch</.link>
              </li>
            <% end %>
          </ul>
        </section>
      </section>
    </nav>
    """
  end

  @doc """
  Renders the site footer.
  """
  attr :current_account, Core.Users.Account, default: nil

  def site_footer(assigns) do
    ~H"""
    <footer class="p-5">
      <section class="row">
        <section class="col-2">
          <h5>Section</h5>
          <ul class="nav flex-column">
            <li class="nav-item mb-2">
              <.link href={~p"/"} class="nav-link p-0 text-muted">Home</.link>
            </li>
          </ul>
        </section>

        <section class="col-2">
          <h5>Authentication</h5>
          <ul class="nav flex-column">
            <%= if @current_account do %>
              <li class="nav-item">
                <strong class="nav-link p-0"><%= @current_account.username %></strong>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/settings"} class="nav-link p-0">Account</.link>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/log_out"} method="delete" class="nav-link p-0">
                  Log out
                </.link>
              </li>
            <% else %>
              <li class="nav-item">
                <.link href={~p"/auth/twitch"} class="nav-link p-0">Authenticate via Twitch</.link>
              </li>
            <% end %>
          </ul>
        </section>
      </section>
    </footer>
    """
  end

  defp admin_links(),
    do: [
      {~p"/admin/accounts", "Accounts"},
      {~p"/admin/organizations", "Organizations"},
      {~p"/admin/jobs", "Jobs"},
      {~p"/admin/webhooks", "Webhooks"},
      {~p"/admin/rarities", "Rarities"}
    ]

  defp hall_links(),
    do: [
      {~p"/halls/", "Halls"}
    ]

  defp aggroculture_links(),
    do: [
      {~p"/lop/plants", "Plants"},
      {~p"/lop/seasons", "Seasons"},
      {~p"/lop/champions", "Champions"},
      {~p"/lop/packs", "Packs"},
      {~p"/lop/cards", "Cards"},
      {~p"/lop/matches", "Matches"}
    ]
end
