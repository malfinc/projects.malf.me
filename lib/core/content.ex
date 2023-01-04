defmodule Core.Content do
  @moduledoc """
  Behavior for interacting with user generated content
  """
  import Core.Context

  resource(:webhooks, :webhook, Core.Content.Webhook)
end
