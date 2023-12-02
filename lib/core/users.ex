defmodule Core.Users do
  @moduledoc """
  A set of behavior concerning users, access, and permissions
  """

  import Ecto.Query, warn: false
  require Logger

  use EctoInterface.Read, [Core.Users.Account, :accounts, :account]
  use EctoInterface, [Core.Users.Organization, :organizations, :organization]
  use EctoInterface, [Core.Users.Permission, :permissions, :permission]

  @doc """
  Gets a account by email_address.
  """
  def get_account_by_email_address(email_address) when is_binary(email_address) do
    Core.Repo.get_by(Core.Users.Account, email_address: email_address)
  end

  @doc """
  Find or create an account based on OAuth data.
  """
  @spec find_or_create_account_from_oauth(Ueberauth.Auth.t()) ::
          {:ok, Core.Users.Account.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create_account_from_oauth(%Ueberauth.Auth{} = data) do
    get_account_by_email_address(data.info.email)
    |> case do
      nil ->
        register_account(%{
          name: data.info.name,
          username: data.info.nickname,
          password: Utilities.String.random(),
          email_address: data.info.email,
          provider: "twitch",
          provider_id: data.uid,
          provider_access_token: data.credentials.token,
          provider_refresh_token: data.credentials.refresh_token,
          provider_token_expiration: data.credentials.expires_at,
          provider_scopes: data.credentials.scopes,
          avatar_uri: data.info.image
        })

      account ->
        {:ok, account}
    end
    |> case do
      {:error, changeset} ->
        Logger.error(changeset.errors)

      {:ok, account} ->
        update_account_oauth(
          account,
          %{
            name: data.info.name,
            username: data.info.nickname,
            provider_id: data.uid,
            provider_access_token: data.credentials.token,
            provider_refresh_token: data.credentials.refresh_token,
            provider_token_expiration: data.credentials.expires_at,
            provider_scopes: data.credentials.scopes,
            avatar_uri: data.info.image
          }
        )
    end
  end

  @doc """
  Registers a account.
  """
  @spec register_account(map()) :: {:ok, Core.Users.Account.t()} | {:error, Ecto.Changeset.t()}
  def register_account(attrs) do
    with {:ok, account} <-
           %Core.Users.Account{}
           |> Core.Users.Account.registration_changeset(attrs)
           |> Core.Repo.insert(),
         {:ok, _} <- join_organization_by_slug(account, "global", "default") do
      {:ok, account |> Core.Repo.reload() |> Core.Repo.preload(:organizations)}
    else
      {:error, _} = error -> error
    end
  end

  @doc """
  Updates the accounts details.
  """
  def update_account_oauth(account, attributes) do
    account
    |> Core.Users.Account.oauth_changeset(attributes)
    |> Core.Repo.update()
  end

  @doc """
  Generates a session token.
  """
  def generate_account_session_token(account) do
    {token, account_token} = Core.Users.AccountToken.build_session_token(account)
    Core.Repo.insert!(account_token)
    token
  end

  @doc """
  Confirms a account by the given token.

  If the token matches, the account account is marked as confirmed
  and the token is deleted.
  """
  def confirm_account(token) do
    with {:ok, query} <-
           Core.Users.AccountToken.verify_email_token_query(token, "confirm"),
         %Core.Users.Account{} = account <- Core.Repo.one(query),
         {:ok, %{account: account}} <-
           Core.Repo.transaction(confirm_account_multi(account)) do
      {:ok, account}
    else
      _ -> :error
    end
  end

  defp confirm_account_multi(account) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Core.Users.Account.confirm_changeset(account))
    |> Ecto.Multi.delete_all(
      :tokens,
      Core.Users.AccountToken.account_and_contexts_query(account, ["confirm"])
    )
  end

  @doc """
  Gets the account with the given signed token.
  """
  def get_account_by_session_token(token) do
    {:ok, query} = Core.Users.AccountToken.verify_session_token_query(token)
    Core.Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_account_session_token(token) do
    Core.Repo.delete_all(Core.Users.AccountToken.token_and_context_query(token, "session"))

    :ok
  end

  @spec join_organization(Core.Users.Account.t(), Core.Users.Organization.t(), String.t()) ::
          {:ok, Core.Users.Organization.t()}
          | {:error, :not_found | Ecto.Changeset.t(Core.Users.OrganizationPermission.t())}
  def join_organization(account, organization, permission_slug) do
    with permission when is_struct(permission, Core.Users.Permission) <-
           Core.Repo.get_by(Core.Users.Permission, %{slug: permission_slug}),
         {:ok, organization_membership} <-
           Core.Users.create_organization_membership(%{
             organization: organization,
             account: account
           }),
         {:ok, _} <-
           Core.Users.create_organization_permission(%{
             organization_membership: organization_membership,
             permission: permission
           }) do
      {:ok, organization}
    else
      nil -> {:error, {Core.Users.Permission, :not_found}}
      error -> error
    end
  end

  @spec join_organization_by_slug(Core.Users.Account.t(), String.t()) ::
          {:ok, Core.Users.Organization.t()}
          | {:error, :not_found | Ecto.Changeset.t(Core.Users.OrganizationPermission.t())}
  def join_organization_by_slug(account, organization_slug) do
    join_organization_by_slug(account, organization_slug, "default")
  end

  @spec join_organization_by_slug(Core.Users.Account.t(), String.t(), String.t()) ::
          {:ok, Core.Users.Organization.t()}
          | {:error, :not_found | Ecto.Changeset.t(Core.Users.OrganizationPermission.t())}
  def join_organization_by_slug(account, organization_slug, permission_slug) do
    join_organization(
      account,
      Core.Repo.get_by(Core.Users.Organization, %{slug: organization_slug}),
      permission_slug
    )
  end

  @spec has_permission?(Core.Users.Account.t() | nil, String.t(), String.t()) :: boolean()
  def has_permission?(nil, _, _), do: false

  def has_permission?(account, organization_slug, permission_slug) do
    from(
      organization_permission in Core.Users.OrganizationPermission,
      join: account in assoc(organization_permission, :account),
      join: permission in assoc(organization_permission, :permission),
      join: organization in assoc(organization_permission, :organization),
      where:
        permission.slug == ^permission_slug and
          organization.slug == ^organization_slug and
          account.id == ^account.id
    )
    |> Core.Repo.exists?()
  end

  def create_organization_membership(attributes) do
    %Core.Users.OrganizationMembership{}
    |> Core.Users.OrganizationMembership.changeset(attributes)
    |> Core.Repo.insert()
  end

  def create_organization_permission(attributes) do
    %Core.Users.OrganizationPermission{}
    |> Core.Users.OrganizationPermission.changeset(attributes)
    |> Core.Repo.insert()
  end
end
