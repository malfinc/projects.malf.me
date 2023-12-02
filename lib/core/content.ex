defmodule Core.Content do
  @moduledoc """
  Behavior for interacting with user generated content
  """

  use EctoInterface, [Core.Content.Webhook, :webhooks, :webhook]
  use EctoInterface, [Core.Content.Nomination, :nominations, :nomination]
  use EctoInterface, [Core.Content.Vote, :votes, :vote]
  use EctoInterface, [Core.Content.Hall, :halls, :hall]
end
