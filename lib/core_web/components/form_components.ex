defmodule CoreWeb.FormComponents do
  @moduledoc """
  Provides form UI components.
  """
  use Phoenix.Component
  use CoreWeb, :verified_routes

  # alias Phoenix.LiveView.JS
  # import CoreWeb.Gettext

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :id, :any, default: nil
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :title, doc: "the title of the form"
  slot :subtitle, doc: "the subtitle of the form"
  slot :description, doc: "a description of the form"
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <%= render_slot(@inner_block, f) %>
      <h3 :if={render_slot(@title)} class="text-2xl font-semibold leading-7 text-gray-900 border-b border-gray-200"><%= render_slot(@title) %> <span :if={render_slot(@subtitle)} class="text-sm ml-3 text-gray-500"><%= render_slot(@subtitle) %></span></h3>
      <p :if={render_slot(@description)} class="mt-1 text-sm leading-6 text-gray-600"><%= render_slot(@description) %></p>
      <div :for={action <- @actions} class="actionset mt-3">
        <%= render_slot(action, f) %>
      </div>
    </.form>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :details, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email_address]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class="form-check" phx-feedback-for={@name}>
      <input type="hidden" name={@name} value="false" />
      <input type="checkbox" id={@id} name={@name} value="true" checked={@checked} class={"form-check-input #{unless(Enum.empty?(@errors), do: "is-invalid")}"} {@rest} />
      <label class="form-check-label"><%= @label %></label>
      <div :if={@details || @rest[:required]} class="form-text"><span :if={@rest[:required]} class="italic">Required.</span> <%= @details %></div>
      <.error :for={msg <- @errors} describing={@id}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="mb-3">
      <.label for={@id}><%= @label %></.label>
      <select id={@id} name={@name} class={"form-select #{unless(Enum.empty?(@errors), do: "is-invalid")}"} multiple={@multiple} aria-describedby={"#{@id}-feedback"} {@rest}>
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <div :if={@details || @rest[:required]} class="form-text"><span :if={@rest[:required]} class="italic">Required.</span> <%= @details %></div>
      <.error :for={msg <- @errors} describing={@id}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="mb-3">
      <.label for={@id}><%= @label %></.label>
      <textarea id={@id} name={@name} class={"form-control #{unless(Enum.empty?(@errors), do: "is-invalid")}"} aria-describedby={"#{@id}-feedback"} {@rest}><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <div :if={@details || @rest[:required]} class="form-text"><span :if={@rest[:required]} class="italic">Required.</span> <%= @details %></div>
      <.error :for={msg <- @errors} describing={@id}><%= msg %></.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="mb-3">
      <.label for={@id}><%= @label %></.label>
      <input type={@type} name={@name} id={@id} value={Phoenix.HTML.Form.normalize_value(@type, @value)} class={"form-control #{unless(Enum.empty?(@errors), do: "is-invalid")}"} aria-describedby={"#{@id}-feedback"} {@rest} />
      <div :if={@details} class="form-text"><%= @details %></div>
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
    <div id={if(@describing, do: "#{@describing}_feedback")} class="phx-no-feedback:hidden invalid-feedback">
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
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
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
end
