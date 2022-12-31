defmodule Core.Twitch do
  @origin_uri "https://api.twitch.tv"
  @eventsub_endpoint ""
  @common_headers [
    {"Client-Id", "xxx"},
    {"Authorization", "Bearer yyy"}
  ]

  def subscribe() do
    :post
    |> Finch.build(
      "#{@origin_uri}/helix/eventsub/subscriptions",
      [
        {"Content-Type", "application/json"}
        | @common_headers
      ],
      Jason.encode!(%{
        "type" => "",
        "version" => "1",
        "condition" => %{
          "broadcaster_user_id" => nil,
          "reward_id" => nil
        },
        "transport" => %{
          "method" => "webhook",
          "callback" => nil,
          "secret" => nil
        }
      })
    )
    |> Finch.request(Core.Finch)
  end
  #   {
  #     "subscription": {
  #         "id": "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
  #         "type": "channel.channel_points_custom_reward_redemption.add",
  #         "version": "1",
  #         "status": "enabled",
  #         "cost": 0,
  #         "condition": {
  #             "broadcaster_user_id": "1337",
  #             "reward_id": "92af127c-7326-4483-a52b-b0da0be61c01" // optional; gets notifications for a specific reward
  #         },
  #          "transport": {
  #             "method": "webhook",
  #             "callback": "https://example.com/webhooks/callback"
  #         },
  #         "created_at": "2019-11-16T10:11:12.634234626Z"
  #     },
  #     "event": {
  #         "id": "17fa2df1-ad76-4804-bfa5-a40ef63efe63",
  #         "broadcaster_user_id": "1337",
  #         "broadcaster_user_login": "cool_user",
  #         "broadcaster_user_name": "Cool_User",
  #         "user_id": "9001",
  #         "user_login": "cooler_user",
  #         "user_name": "Cooler_User",
  #         "user_input": "pogchamp",
  #         "status": "unfulfilled",
  #         "reward": {
  #             "id": "92af127c-7326-4483-a52b-b0da0be61c01",
  #             "title": "title",
  #             "cost": 100,
  #             "prompt": "reward prompt"
  #         },
  #         "redeemed_at": "2020-07-15T17:16:03.17106713Z"
  #     }
  # }
  def handle_webhook(%{
    "subscription" => %{"type" => "channel.channel_points_custom_reward_redemption.add"},
    "event" => event
  }) do
    give_points(account, amount)
  end
end
