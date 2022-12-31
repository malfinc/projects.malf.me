defmodule CoreWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
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
              <.link href="#">League of Plants</.link>
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
  attr :admin_namespace, :boolean, default: false

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
            <%= if @current_account do %>
              <%= if Core.Users.has_permission?(@current_account, "global", "administrator") do %>
                <li class="nav-item">
                  <.link href={~p"/admin"} class="nav-link">
                    Admin
                  </.link>
                </li>
              <% end %>

              <%= if @admin_namespace do %>
                <%= for {path, name} <- admin_links() do %>
                  <li class="nav-item">
                    <.link href={path} class="nav-link">
                      <%= name %>
                    </.link>
                  </li>
                <% end %>
              <% end %>
            <% end %>
          </ul>

          <ul class="navbar-nav me-right mb-2 mb-lg-0">
            <%= if @current_account do %>
              <li class="nav-item">
                <%= @current_account.email_address %>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/settings"} class="nav-link">Settings</.link>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/log_out"} method="delete" class="nav-link">Log out</.link>
              </li>
            <% else %>
              <li class="nav-item">
                <.link href={~p"/accounts/register"} class="nav-link">Register</.link>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/log_in"} class="nav-link">Log in</.link>
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
                <strong class="nav-link"><%= @current_account.username %></strong>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/settings"} class="nav-link p-0">Settings</.link>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/log_out"} method="delete" class="nav-link p-0">
                  Log out
                </.link>
              </li>
            <% else %>
              <li class="nav-item">
                <.link href={~p"/accounts/register"} class="nav-link p-0">Register</.link>
              </li>
              <li class="nav-item">
                <.link href={~p"/accounts/log_in"} class="nav-link p-0">Log in</.link>
              </li>
            <% end %>
          </ul>
        </section>
      </section>
    </footer>
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
      style="margin-top: 5px; "
      {@rest}
      {@rest}
    >
      <p :if={@title}>
        icon <%= @title %>
      </p>
      <div><%= msg %></div>
      <.button :if={@close} class="btn-close" data-bs-dismiss="alert" aria-label="close"></.button>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form :let={f} for={:user} phx-change="validate" phx-submit="save">
        <.input field={{f, :email_address}} label="Email"/>
        <.input field={{f, :username}} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, default: nil, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <%= if @for do %>
      <.form :let={f} for={@for} as={@as} class="form" novalidate {@rest}>
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="actionset">
          <%= render_slot(action, f) %>
        </div>
      </.form>
    <% else %>
      <.form :let={f} for={@for} as={@as} class="form" {@rest}>
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="actionset">
          <%= render_slot(action, f) %>
        </div>
      </.form>
    <% end %>
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

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={{f, :email}} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any
  attr :name, :any
  attr :label, :string, default: nil

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :value, :any

  attr :field, :any,
    doc: "a %Phoenix.HTML.Form{}/field name tuple, for example: {f, :email_address}"

  attr :errors, :list
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :rest, :global, include: ~w(autocomplete disabled form max maxlength min minlength
                                   pattern placeholder readonly required size step)
  slot :inner_block

  def input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn ->
      name = Phoenix.HTML.Form.input_name(f, field)
      if assigns.multiple, do: name <> "[]", else: name
    end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> assign_new(:errors, fn -> translate_errors(f.errors || [], field) end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> input_equals?(assigns.value, "true") end)

    ~H"""
    <div class={"form-check #{unless(Enum.empty?(@errors), do: "is-invalid")}"}>
      <input type="hidden" name={@name} value="false" />
      <input
        type="checkbox"
        id={@id || @name}
        name={@name}
        value="true"
        checked={@checked}
        class="form-check-input"
        {@rest}
        {@rest}
      />
      <label phx-feedback-for={@name} class="form-check-label"><%= @label %></label>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class={"form-select #{unless(Enum.empty?(@errors), do: "is-invalid")}"}
        multiple={@multiple}
        aria-describedby={"#{@id}-feedback"}
        {@rest}
        {@rest}
      >
        <option :if={@prompt}><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors} describing={@id}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id || @name}
        name={@name}
        class={"form-control #{unless(Enum.empty?(@errors), do: "is-invalid")}"}
        aria-describedby={"#{@id}-feedback"}
        {@rest}
        {@rest}
      ><%= @value %></textarea>
      <.error :for={msg <- @errors} describing={@id}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={@value}
        class={"form-control #{unless(Enum.empty?(@errors), do: "is-invalid")}"}
        aria-describedby={"#{@id}-feedback"}
        {@rest}
        {@rest}
      />
      <.error :for={msg <- @errors} describing={@id}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="form-label">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  attr :describing, :string, default: nil
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <div
      id={if(@describing, do: "#{@describing}_feedback")}
      class="phx-no-feedback:hidden invalid-feedback"
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(CoreWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(CoreWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  defp input_equals?(val1, val2) do
    Phoenix.HTML.html_escape(val1) == Phoenix.HTML.html_escape(val2)
  end

  defp admin_links(),
    do: [
      {~p"/admin/accounts", "Accounts"},
      {~p"/admin/organizations", "Organizations"},
      {~p"/admin/jobs", "Jobs"}
    ]
end
