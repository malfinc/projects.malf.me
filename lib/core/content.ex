defmodule Core.Content do
  @moduledoc """
  Behavior for interacting with user generated content
  """

  use Scaffolding, [Core.Content.Webhook, :webhooks, :webhook]
  use Scaffolding, [Core.Content.Nomination, :nominations, :nomination]
  use Scaffolding, [Core.Content.Vote, :votes, :vote]
  use Scaffolding, [Core.Content.Hall, :halls, :hall]
end
