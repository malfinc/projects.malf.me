defmodule CoreWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use CoreWeb, :controller
      use CoreWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller, namespace: CoreWeb

      import Plug.Conn
      import CoreWeb.Gettext
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {CoreWeb.LayoutView, :live}

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      on_mount({CoreWeb, :check_for_admin_namespace})
      on_mount({CoreWeb, :authentication})
      on_mount({CoreWeb, :listen_to_session})

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView
      import Phoenix.Component

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import CoreWeb.ErrorHelpers
      import CoreWeb.Gettext

      # Include shared imports and aliases for views
      unquote(view_helpers())
      unquote(live_view_helpers())
      unquote(component_helpers())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/core_web/templates",
        namespace: CoreWeb,
        layout: {CoreWeb.LayoutView, :app}

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
      unquote(component_helpers())
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import CoreWeb.Gettext
    end
  end

  def view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.LiveView
      import Phoenix.Component
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import CoreWeb.ErrorHelpers
      import CoreWeb.Gettext
    end
  end

  def live_view_helpers do
    quote do
      def handle_info({:live_session_updated, _session}, socket),
        do: socket |> Utilities.Tuple.result(:noreply)
    end
  end

  def component_helpers do
    quote do
      def timestamp_in_words_ago(%{updated_at: updated_at}) do
        Timex.from_now(updated_at)
      end

      def timestamp_in_words_ago(%{inserted_at: inserted_at}) do
        Timex.from_now(inserted_at)
      end

      def code_as_html(source) do
        inspect(source, pretty: true, limit: :infinity)
        |> (&"```\n#{&1}\n```").()
        |> Earmark.as_html!()
        |> Phoenix.HTML.raw()
      end

      def error_at_ago(%{"at" => at}) do
        at
        |> DateTime.from_iso8601()
        |> case do
          {:ok, datetime, _} -> Timex.from_now(datetime)
          {:error, _} -> at
        end
      end
    end
  end

  @spec on_mount(
          atom(),
          map(),
          map(),
          any
        ) :: {atom, any}
  def on_mount(:listen_to_session, _params, session, socket) do
    socket
    |> PhoenixLiveSession.maybe_subscribe(session)
    |> Utilities.Tuple.result(:cont)
  end

  # Move to Core.Plugs.Admin
  def on_mount(:check_for_admin_namespace, _params, %{"admin_namespace" => true}, socket) do
    socket
    |> Phoenix.Component.assign(:admin_namespace, true)
    |> Utilities.Tuple.result(:cont)
  end

  # Move to Core.Plugs.Admin
  def on_mount(:check_for_admin_namespace, _params, _session, socket) do
    socket
    |> Phoenix.Component.assign_new(:admin_namespace, fn -> false end)
    |> Utilities.Tuple.result(:cont)
  end

  def on_mount(:authentication, _params, session, socket) do
    socket
    |> CoreWeb.AccountAuthenticationHelpers.fetch_current_account(session)
    |> Utilities.Tuple.result(:cont)
  end

  # Move to Core.Plugs.Admin
  def on_mount(
        :require_administrative_privilages,
        _params,
        _session,
        %{assigns: %{current_account: current_account}} = socket
      ) do
    current_account
    |> Core.Users.has_permission?("global", "administrator")
    |> case do
      true ->
        socket
        |> Utilities.Tuple.result(:cont)

      false ->
        socket
        |> Phoenix.LiveView.put_flash(:error, "That page does not exist")
        |> Phoenix.LiveView.redirect(to: "/")
        |> Utilities.Tuple.result(:halt)
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
