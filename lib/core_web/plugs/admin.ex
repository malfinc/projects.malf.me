defmodule CoreWeb.Plugs.Admin do
  @moduledoc """
  This plug intercepts requests for the admin resoures and tells the application it's in admin mode.
  """
  import Plug.Conn
  require Logger

  def init(_), do: nil

  def call(%Plug.Conn{path_info: ["admin" | _]} = conn, _) do
    conn
    |> assign(:admin_namespace, true)
    |> put_session(:admin_namespace, true)
  end

  def call(conn, _) do
    conn
    |> assign(:admin_namespace, false)
    |> put_session(:admin_namespace, false)
  end
end
