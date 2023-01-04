defmodule CoreWeb.TwitchWebhookController do
  use CoreWeb, :controller

  def create(
        conn,
        %{
          "subscription" => %{"status" => "webhook_callback_verification_pending"},
          "challenge" => challenge
        } = payload
      ) do
    record_webhook(payload, conn.req_headers)

    conn
    |> put_status(200)
    |> text(challenge)
  end

  @doc """
  Reward Redemption payload:

  ```
  {
      "subscription": {
          "id": "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
          "type": "channel.channel_points_custom_reward_redemption.add",
          "version": "1",
          "status": "enabled",
          "cost": 0,
          "condition": {
              "broadcaster_user_id": "1337",
              "reward_id": "92af127c-7326-4483-a52b-b0da0be61c01" // optional; gets notifications for a specific reward
          },
           "transport": {
              "method": "webhook",
              "callback": "https://example.com/webhooks/callback"
          },
          "created_at": "2019-11-16T10:11:12.634234626Z"
      },
      "event": {
          "id": "17fa2df1-ad76-4804-bfa5-a40ef63efe63",
          "broadcaster_user_id": "1337",
          "broadcaster_user_login": "cool_user",
          "broadcaster_user_name": "Cool_User",
          "user_id": "9001",
          "user_login": "cooler_user",
          "user_name": "Cooler_User",
          "user_input": "pogchamp",
          "status": "unfulfilled",
          "reward": {
              "id": "92af127c-7326-4483-a52b-b0da0be61c01",
              "title": "title",
              "cost": 100,
              "prompt": "reward prompt"
          },
          "redeemed_at": "2020-07-15T17:16:03.17106713Z"
      }
  }
  ```

  Cheer Webhook payload:

  ```
  {
      "subscription": {
          "id": "f1c2a387-161a-49f9-a165-0f21d7a4e1c4",
          "type": "channel.cheer",
          "version": "1",
          "status": "enabled",
          "cost": 0,
          "condition": {
              "broadcaster_user_id": "1337"
          },
          "transport": {
              "method": "webhook",
              "callback": "https://example.com/webhooks/callback"
          },
          "created_at": "2019-11-16T10:11:12.634234626Z"
      },
      "event": {
          "is_anonymous": false,
          "user_id": "1234",          // null if is_anonymous=true
          "user_login": "cool_user",  // null if is_anonymous=true
          "user_name": "Cool_User",   // null if is_anonymous=true
          "broadcaster_user_id": "1337",
          "broadcaster_user_login": "cooler_user",
          "broadcaster_user_name": "Cooler_User",
          "message": "pogchamp",
          "bits": 1000
      }
  }
  ```
  """
  def create(
        conn,
        %{
          "subscription" => %{"type" => "channel.channel_points_custom_reward_redemption.add"},
          "event" => %{
            "user_id" => twitch_user_id,
            "reward" => %{
              "cost" => amount
            }
          }
        } = payload
      ) do
    record_webhook(payload, conn.req_headers)
    give_coins("channel point redemption", twitch_user_id, amount / 20000)

    conn
    |> put_status(200)
    |> text("OK")
  end

  def create(
        conn,
        %{
          "subscription" => %{"type" => "channel.subscription.gift"},
          "event" => %{
            "user_id" => twitch_user_id
          }
        } = payload
      ) do
    record_webhook(payload, conn.req_headers)
    give_coins("gift subscription", twitch_user_id, 1)

    conn
    |> put_status(200)
    |> text("OK")
  end

  def create(
        conn,
        %{
          "subscription" => %{"type" => "channel.subscribe"},
          "event" => %{
            "user_id" => twitch_user_id
          }
        } = payload
      ) do
    record_webhook(payload, conn.req_headers)
    give_coins("subscription", twitch_user_id, 1)

    conn
    |> put_status(200)
    |> text("OK")
  end

  def create(
        conn,
        %{
          "subscription" => %{"type" => "channel.subscription.message"},
          "event" => %{
            "user_id" => twitch_user_id
          }
        } = payload
      ) do
    record_webhook(payload, conn.req_headers)
    give_coins("resubscription", twitch_user_id, 1)

    conn
    |> put_status(200)
    |> text("OK")
  end

  def create(
        conn,
        %{
          "subscription" => %{"type" => "channel.cheer"},
          "event" => %{
            "user_id" => twitch_user_id,
            "bits" => bits
          }
        } = payload
      ) do
    record_webhook(payload, conn.req_headers)
    give_coins("cheer", twitch_user_id, bits / 500)

    conn
    |> put_status(200)
    |> text("OK")
  end

  defp give_coins(reason, twitch_user_id, amount) do
    %{
      twitch_user_id: twitch_user_id,
      value: Float.ceil(amount),
      reason: reason
    }
    |> Core.Job.DepositCoinJob.new()
    |> Oban.insert()
  end

  defp record_webhook(payload, headers) do
    Core.Content.create_webhook(%{
      provider: "twitter",
      payload: payload,
      headers: headers
    })
  end
end
