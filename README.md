# Core

## Libraries

  - https://gijsroge.github.io/tilt.js/


## Twitch OAuth Payload

``` elixir
%Ueberauth.Auth{
  uid: "36808632",
  provider: :twitch,
  strategy: Ueberauth.Strategy.Twitch,
  info: %Ueberauth.Auth.Info{
    name: "krainboltgreene",
    first_name: nil,
    last_name: nil,
    nickname: "krainboltgreene",
    email: "kurtis@rainbolt-greene.online",
    location: nil,
    description: "Programmer, sometime artist, sometime writer, & intersectional feminist.",
    image: "https://static-cdn.jtvnw.net/jtv_user_pictures/f6fb8ff7-1055-414f-86a8-7d2302b58e6f-profile_image-300x300.jpg",
    phone: nil,
    birthday: nil,
    urls: %{}
  },
  credentials: %Ueberauth.Auth.Credentials{
    token: "...",
    refresh_token: "...",
    token_type: nil,
    secret: nil,
    expires: true,
    expires_at: 1672456087,
    scopes: ["user:read:email"],
    other: %{}
  },
  extra: %Ueberauth.Auth.Extra{
    raw_info: %{
    token: %OAuth2.AccessToken{
      access_token: "s77vyzbw7v5yjsl3ya2vvfm6jigo6f",
      refresh_token: "uaftj0trsgh311s6js0pbp09b87ctaj5tstk8rpeq1xvs26nfj",
      expires_at: 1672456087,
      token_type: "Bearer",
      other_params: %{
        "scope" => ["user:read:email"]
      }
    },
    user: %{
      "data" => [
        %{
          "broadcaster_type" => "",
          "created_at" => "2012-10-10T17:53:56Z",
          "description" => "Programmer, sometime artist, sometime writer, & intersectional feminist.",
          "display_name" => "krainboltgreene",
          "email" => "kurtis@rainbolt-greene.online",
          "id" => "36808632",
          "login" => "krainboltgreene",
          "offline_image_url" => "",
          "profile_image_url" => "https://static-cdn.jtvnw.net/jtv_user_pictures/f6fb8ff7-1055-414f-86a8-7d2302b58e6f-profile_image-300x300.jpg",
          "type" => "",
          "view_count" => 83
        }
      ]
    }
  }
}
}
```


## Setting up phoenix

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
