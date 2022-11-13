defmodule CoreWeb.Live.SiteFooter do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> Utilities.Tuple.result(:ok, layout: false)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <footer class="p-5">
      <section class="row">
        <section class="col-2">
          <h5>Section</h5>
          <ul class="nav flex-column">
            <li class="nav-item mb-2">
              <%= link(to: Routes.page_path(@socket, :index), class: "nav-link p-0 text-muted") do %>Home<% end %>
            </li>
          </ul>
        </section>

        <section class="col-2">
          <h5>Authentication</h5>
          <ul class="nav flex-column">
            <%= if assigns[:current_account] do %>
              <li class="nav-item">
                <%= @current_account.email_address %>
              </li>
              <li class="nav-item">
                <%= link to: Routes.account_settings_path(@socket, :edit), class: "nav-link p-0" do %>Settings<% end %>
              </li>
              <li class="nav-item">
                <%= link to: Routes.account_session_path(@socket, :delete), method: :delete, class: "nav-link p-0" do %>Log out<% end %>
              </li>
            <% else %>
              <li class="nav-item">
                <%= link to: Routes.account_registration_path(@socket, :new), class: "nav-link p-0" do %>Register<% end %>
              </li>
              <li class="nav-item">
                <strong><%= link to: Routes.account_session_path(@socket, :new), class: "nav-link p-0" do %>Log in<% end %></strong>
              </li>
            <% end %>
          </ul>
        </section>

        <section class="col-4 offset-1">
          <form>
            <h5>Subscribe to our newsletter</h5>
            <p>Monthly digest of whats new and exciting from us.</p>
            <section class="d-flex w-100 gap-2">
              <label for="newsletter1" class="visually-hidden">
                Email address
              </label>
              <input id="newsletter1" type="text" class="form-control" placeholder="Email address">
              <button class="btn btn-primary" type="button">
                Subscribe
              </button>
            </section>
          </form>
        </section>
      </section>
    </footer>
    """
  end
end
