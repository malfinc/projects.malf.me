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
    {:ok, krainboltgreene} =
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
        avatar_uri:
          "https://static-cdn.jtvnw.net/jtv_user_pictures/f6fb8ff7-1055-414f-86a8-7d2302b58e6f-profile_image-300x300.jpg"
      })

    {encoded_token, account_token} =
      Core.Users.AccountToken.build_email_token(krainboltgreene, "confirm")

    {:ok, _} = Core.Repo.insert(account_token)
    {:ok, _} = Core.Users.confirm_account(encoded_token)

    {:ok, _organization} =
      Core.Users.join_organization_by_slug(krainboltgreene, "global", "administrator")
  end)
end

# Reset the log level back to normal
Logger.configure(level: previous_log_level)
