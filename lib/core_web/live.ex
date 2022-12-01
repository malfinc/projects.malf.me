defmodule CoreWeb.Live do
  @moduledoc """
  A collection of live helpers
  """
  @spec on_mount(
          atom(),
          map(),
          map(),
          any
        ) :: {atom, any}
  def on_mount(:listen_to_session, _params, session, socket) do
    socket
    |> PhoenixLiveSession.maybe_subscribe(session)
    |> (&{:cont, &1}).()
  end
end
