defmodule Core.Client.TwitchClient do
  @moduledoc """
  All behavior having to do with Twitch's API
  """
  @authentication_uri "https://id.twitch.tv"
  @origin_uri URI.parse("https://api.twitch.tv")
  @common_headers [
    {"User-Agent", "malfworld v1"}
  ]
  @broadcaster_user_id "19336638"
  @subscription_types [
    "channel.channel_points_custom_reward_redemption.add",
    "channel.subscription.gift",
    "channel.subscribe",
    "channel.subscription.message"
  ]

  def search_games(name, token \\ fetch_access_token()) do
    :get
    |> Finch.build(
      @origin_uri
      |> URI.merge("/helix/search/categories")
      |> URI.append_query(URI.encode_query(%{"query" => name})),
      [
        {"Client-Id", Application.get_env(:core, :secrets)["twitch"]["client_id"]},
        {"Authorization", "Bearer #{token}"}
        | @common_headers
      ]
    )
    |> Finch.request(Core.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200} = response} -> Jason.decode(response.body)
    end
  end

  def revoke_access_token(access_token) do
    :post
    |> Finch.build(
      @authentication_uri
      |> URI.merge("/oauth2/revoke"),
      [
        {"Content-Type", "application/x-www-form-urlencoded"}
        | @common_headers
      ],
      "client_id=#{Application.get_env(:core, :secrets)["twitch"]["client_id"]}&token=#{access_token}"
    )
    |> Finch.request(Core.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200} = response} -> Jason.decode(response.body)
    end
  end

  def fetch_access_token() do
    :post
    |> Finch.build(
      @authentication_uri
      |> URI.merge("/oauth2/token"),
      [
        {"Content-Type", "application/x-www-form-urlencoded"}
        | @common_headers
      ],
      "client_id=#{Application.get_env(:core, :secrets)["twitch"]["client_id"]}&client_secret=#{Application.get_env(:core, :secrets)["twitch"]["client_secret"]}&grant_type=client_credentials"
    )
    |> Finch.request(Core.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200} = response} -> Jason.decode(response.body)
    end
    |> case do
      {:ok, %{"access_token" => access_token}} -> access_token
    end
  end

  def stop_event_subscription(event_subscription_id, token \\ fetch_access_token()) do
    :delete
    |> Finch.build(
      @origin_uri
      |> URI.merge("/helix/eventsub/subscriptions")
      |> URI.append_query(URI.encode_query(%{"id" => event_subscription_id})),
      [
        {"Client-Id", Application.get_env(:core, :secrets)["twitch"]["client_id"]},
        {"Authorization", "Bearer #{token}"}
        | @common_headers
      ]
    )
    |> Finch.request(Core.Finch)
  end

  def list_event_subscriptions(token \\ fetch_access_token()) do
    :get
    |> Finch.build(
      @origin_uri
      |> URI.merge("/helix/eventsub/subscriptions"),
      [
        {"Client-Id", Application.get_env(:core, :secrets)["twitch"]["client_id"]},
        {"Authorization", "Bearer #{token}"}
        | @common_headers
      ]
    )
    |> Finch.request(Core.Finch)
    |> case do
      {:ok, %Finch.Response{status: 200} = response} -> Jason.decode(response.body)
    end
  end

  def start_event_subscription() do
    @subscription_types
    |> Enum.map(fn subscription_type ->
      start_event_subscription(subscription_type)
    end)
  end

  def start_event_subscription(type, token \\ fetch_access_token()) do
    :post
    |> Finch.build(
      @origin_uri
      |> URI.merge("/helix/eventsub/subscriptions"),
      [
        {"Content-Type", "application/json"},
        {"Client-Id", Application.get_env(:core, :secrets)["twitch"]["client_id"]},
        {"Authorization", "Bearer #{token}"}
        | @common_headers
      ],
      Jason.encode!(%{
        "type" => type,
        "version" => "1",
        "condition" => %{
          "broadcaster_user_id" => @broadcaster_user_id
        },
        "transport" => %{
          "method" => "webhook",
          "callback" =>
            "#{Application.get_env(:core, :base_url)}#{Application.get_env(:core, :twitch)[:webhook_path]}",
          "secret" => "xxxxxxxxxx"
        }
      })
    )
    |> Finch.request(Core.Finch)
    |> case do
      {:ok, %Finch.Response{status: 202} = response} -> Jason.decode(response.body)
    end
  end
end
