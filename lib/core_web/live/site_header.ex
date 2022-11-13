defmodule CoreWeb.Live.SiteHeader do
  @moduledoc false
  use CoreWeb, :live_view

  defp admin_links(),
    do: [
      {:admin_account_path, "Accounts"},
      {:admin_organization_path, "Organizations"},
      {:admin_job_path, "Jobs"}
    ]

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> Utilities.Tuple.result(:ok, layout: false)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <nav class="navbar navbar-expand-lg navbar-dark  bg-dark ">
      <section class="container-fluid">
        <%= link(to: Routes.page_path(@socket, :index), class: "navbar-brand") do %>
          <img
            src={Routes.static_path(@socket, "/images/banner-logo.svg")}
            alt="the malf logo, which is two triangles arranged in a way that makes a cute fox head with ears"
            title="the malf logo, which is two triangles arranged in a way that makes a cute fox head with ears"
          />
        <% end %>
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
              <a class="nav-link" href="https://www.twitch.tv/michaelalfox">Watch</a>
            </li>
            <li class="nav-item"><a class="nav-link" href="#blog_link_here">Blog</a></li>
            <li class="nav-item">
              <%= link to: Routes.page_path(@socket, :socials), class: "nav-link" do %>
                Socials
              <% end %>
            </li>
            <li class="nav-item">
              <%= link to: Routes.page_path(@socket, :discord), class: "nav-link" do %>
                Discord
              <% end %>
            </li>
            <li class="nav-item">
              <%= link to: Routes.page_path(@socket, :about), class: "nav-link" do %>
                About
              <% end %>
            </li>
            <li class="nav-item">
              <%= link to: Routes.page_path(@socket, :projects), class: "nav-link" do %>
                Projects
              <% end %>
            </li>
            <li class="nav-item">
              <%= link to: Routes.page_path(@socket, :contact), class: "nav-link" do %>
                Contact
              <% end %>
            </li>
            <%= if @current_account do %>
              <%= if Core.Users.has_permission?(@current_account, "global", "administrator") do %>
                <li class="nav-item">
                  <%= link to: Routes.admin_live_path(@socket, CoreWeb.Live.AdminPage), class: "nav-link" do %>
                    Admin
                  <% end %>
                </li>
              <% end %>

              <%= if @admin_namespace do %>
                <%= for {function, name} <- admin_links() do %>
                  <li class="nav-item">
                    <%= link to: apply(Routes, function, [@socket, :list]), class: "nav-link" do %>
                      <%= name %>
                    <% end %>
                  </li>
                <% end %>
              <% end %>
            <% end %>
          </ul>

          <ul class="navbar-nav me-right mb-2 mb-lg-0">
            <%= if @current_account do %>
              <li class="nav-item">
                <%= link to: Routes.account_settings_path(@socket, :edit), class: "nav-link" do %>
                  <%= @current_account.email_address %>
                <% end %>
              </li>
              <li class="nav-item">
                <%= link to: Routes.account_session_path(@socket, :delete), method: :delete, class: "nav-link" do %>
                  Log out
                <% end %>
              </li>
            <% else %>
              <li class="nav-item">
                <%= link to: Routes.account_registration_path(@socket, :new), class: "nav-link" do %>
                  Register
                <% end %>
              </li>
              <li class="nav-item">
                <strong>
                  <%= link to: Routes.account_session_path(@socket, :new), class: "nav-link" do %>
                    Log in
                  <% end %>
                </strong>
              </li>
            <% end %>
          </ul>
        </section>
      </section>
    </nav>
    """
  end
end
