# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Core.Repo.insert!(%Core.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require Logger

# Capture the current log level so we can reset after
previous_log_level = Logger.level()

# Change the log level so we don't see all the debug output.
Logger.configure(level: :info)

if Mix.env() == :dev do
  Core.Repo.transaction(fn ->
    {:ok, account} =
      Core.Users.register_account(%{
        name: "Kurtis Rainbolt-Greene",
        email_address: "kurtis@rainbolt-greene.online",
        username: "krainboltgreene",
        password: "passwordpassword",
        provider: "twitch",
        provider_id: "36808632",
        provider_access_token: "s77vyzbw7v5yjsl3ya2vvfm6jigo6f",
        provider_refresh_token: "uaftj0trsgh311s6js0pbp09b87ctaj5tstk8rpeq1xvs26nfj",
        provider_token_expiration: "1672456087",
        provider_scopes: ["user:read:email"],
        avatar_uri:
          "https://static-cdn.jtvnw.net/jtv_user_pictures/f6fb8ff7-1055-414f-86a8-7d2302b58e6f-profile_image-300x300.jpg"
      })

    {encoded_token, account_token} = Core.Users.AccountToken.build_email_token(account, "confirm")

    {:ok, _} = Core.Repo.insert(account_token)
    {:ok, _} = Core.Users.confirm_account(encoded_token)

    {:ok, _organization} =
      Core.Users.join_organization_by_slug(account, "global", "administrator")

    File.read!("priv/data/plants.csv")
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ~r/\s*,\s*/))
    |> Enum.filter(fn
      [""] -> false
      _ -> true
    end)
    |> Enum.each(fn [name, species, image_uri] ->
      Core.Gameplay.create_plant!(%{
        name: name,
        species: species,
        image_uri: image_uri,
        rarity_symbol: "x"
      })
    end)

    Core.Gameplay.create_rarity!(%{
      name: "Common",
      color: "grey",
      season_pick_rate: 100,
      pack_slot_caps: [2368, 2368, 1664, 0, 0, 0],
      holographic_rate: 10.0,
      full_art_rate: 0.0
    })

    Core.Gameplay.create_rarity!(%{
      name: "Uncommon",
      color: "green",
      season_pick_rate: 75,
      pack_slot_caps: [0, 0, 704, 2368, 1728, 0],
      holographic_rate: 13.33,
      full_art_rate: 50.0
    })

    Core.Gameplay.create_rarity!(%{
      name: "Rare",
      color: "blue",
      season_pick_rate: 30,
      pack_slot_caps: [0, 0, 0, 0, 640, 1280],
      holographic_rate: 100.0,
      full_art_rate: 33.33
    })

    Core.Gameplay.create_rarity!(%{
      name: "Epic",
      color: "yellow",
      season_pick_rate: 11,
      pack_slot_caps: [0, 0, 0, 0, 0, 704],
      holographic_rate: 100.0,
      full_art_rate: 100.0
    })

    Core.Gameplay.create_rarity!(%{
      name: "Legendary",
      color: "orange",
      season_pick_rate: 5,
      pack_slot_caps: [0, 0, 0, 0, 0, 320],
      holographic_rate: 100.0,
      full_art_rate: 100.0
    })

    Core.Gameplay.create_rarity!(%{
      name: "Mythical",
      color: "red",
      season_pick_rate: 1,
      pack_slot_caps: [0, 0, 0, 0, 0, 64],
      holographic_rate: 100.0,
      full_art_rate: 100.0
    })

    season = Core.Gameplay.create_season!(%{plants: Core.Gameplay.list_plants()})
    Oban.insert(Core.Job.StartSeasonJob.new(%{season_id: season.id}))
  end)
end

# Reset the log level back to normal
Logger.configure(level: previous_log_level)
