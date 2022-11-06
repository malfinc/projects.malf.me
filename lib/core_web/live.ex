defmodule CoreWeb.Live do
  @moduledoc """
  This is were all the live view helpers will live
  """
  import Phoenix.Component

  defmacro __using__(:view) do
    quote do
      require Logger

      use Phoenix.LiveView,
        layout: {CoreWeb.LayoutView, :live}

      on_mount({CoreWeb.Live, :check_for_admin_namespace})
      on_mount({CoreWeb.Live, :authentication})

      unquote(on_mounts())
      unquote(CoreWeb.view_helpers())
      unquote(CoreWeb.Live.view_helpers())
    end
  end

  defmacro __using__(:component) do
    quote do
      require Logger
      use Phoenix.LiveComponent

      unquote(on_mounts())
      unquote(CoreWeb.view_helpers())
      unquote(CoreWeb.Live.view_helpers())
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
    |> assign(:admin_namespace, true)
    |> Utilities.Tuple.result(:cont)
  end

  # Move to Core.Plugs.Admin
  def on_mount(:check_for_admin_namespace, _params, _session, socket) do
    socket
    |> assign_new(:admin_namespace, fn -> false end)
    |> Utilities.Tuple.result(:cont)
  end

  def on_mount(:authentication, _params, session, socket) do
    socket
    |> CoreWeb.AccountAuth.fetch_current_account(session)
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

  defp on_mounts() do
    quote do
      on_mount({CoreWeb.Live, :listen_to_session})
    end
  end

  def view_helpers() do
    quote do
      def handle_info({:live_session_updated, _session}, socket),
        do: socket |> Utilities.Tuple.result(:noreply)
    end
  end
end
