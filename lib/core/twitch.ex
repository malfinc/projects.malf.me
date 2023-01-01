defmodule Core.Twitch do
  @authentication_uri "https://id.twitch.tv"
  @origin_uri "https://api.twitch.tv"
  @common_headers [
    {"User-Agent", "league-of-plants v1"}
  ]
  @broadcaster_user_id "19336638"

  def fetch_access_token() do
    :post
    |> Finch.build(
      "#{@authentication_uri}/oauth2/token",
      [
        {"Content-Type", "application/x-www-form-urlencoded"}
        | @common_headers
      ],
      "client_id=#{System.get_env("TWITCH_CLIENT_SECRET")}&client_secret=#{System.get_env("TWITCH_CLIENT_SECRET")}&grant_type=client_credentials"
    )
    |> Finch.request(Core.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200} = response} -> Jason.decode(response.body)
    end
    |> case do
      {:ok, %{"access_token" => access_token}} -> access_token
    end
  end

  def subscribe() do
    :post
    |> Finch.build(
      "#{@origin_uri}/helix/eventsub/subscriptions",
      [
        {"Content-Type", "application/json"},
        {"Client-Id", System.get_env("TWITCH_CLIENT_ID")},
        {"Authorization", "Bearer #{fetch_access_token()}"}
        | @common_headers
      ],
      Jason.encode!(%{
        "type" => "channel.channel_points_custom_reward_redemption.add",
        "version" => "1",
        "condition" => %{
          "broadcaster_user_id" => @broadcaster_user_id,
          # "reward_id" => nil
        },
        "transport" => %{
          "method" => "webhook",
          "callback" => "https://webhook.site/800992df-d520-4f42-bd4f-5eba3f60aa7e",
          "secret" => "xxxxxxxxxx"
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
    dbg(event)
    # give_coins(account, amount)
  end

  def handle_webhook(%{
    "subscription" => %{"type" => "channel.subscription.gift"},
    "event" => event
  }) do
    dbg(event)
    # give_coins(account, amount)
  end

  def handle_webhook(%{
    "subscription" => %{"type" => "channel.subscribe"},
    "event" => event
  }) do
    dbg(event)
    # give_coins(account, amount)
  end

  def handle_webhook(%{
    "subscription" => %{"type" => "channel.subscription.message"},
    "event" => event
  }) do
    dbg(event)
    # give_coins(account, amount)
  end

  def handle_webhook(%{
    "subscription" => %{"type" => "channel.cheer"},
    "event" => event
  }) do
    dbg(event)
    # give_coins(account, amount)
  end
end
