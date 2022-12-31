defmodule Core.Repo.Migrations.AddOauthToAccounts do
  use Ecto.Migration

  def change do
    alter(table(:accounts)) do
      add :provider, :text, null: false
      add :provider_access_token, :text, null: false
      add :provider_refresh_token, :text, null: false
      add :provider_token_expiration, :integer, null: false
      add :provider_id, :text, null: false
      add :avatar_uri, :text, null: false
    end
  end
end
