defmodule CoreWeb.Router do
  use CoreWeb, :router

  import CoreWeb.AccountAuthenticationHelpers
  import Phoenix.LiveDashboard.Router

  import CoreWeb.Plugs.Administration,
    only: [require_administrative_privilages: 2]

  import CoreWeb.Plugs.Namespace,
    only: [set_namespace: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CoreWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth" do
    pipe_through :browser

    get "/:provider", CoreWeb.AccountSessionController, :request
    get "/:provider/callback", CoreWeb.AccountSessionController, :callback
  end

  scope "/twitch/webhooks" do
    pipe_through [:api]

    post "/", CoreWeb.TwitchWebhookController, :create
  end

  scope "/" do
    pipe_through [:browser, :redirect_if_account_is_authenticated]

    live_session :redirect_if_account_is_authenticated,
      on_mount: [{CoreWeb.AccountAuthenticationHelpers, :redirect_if_account_is_authenticated}] do
      live "/accounts/log_in", CoreWeb.AccountLoginLive, :new
    end

    post "/accounts/log_in", CoreWeb.AccountSessionController, :create
  end

  scope "/" do
    pipe_through [:browser]

    delete "/accounts/log_out", CoreWeb.AccountSessionController, :delete
  end

  scope "/" do
    pipe_through [:browser]

    live_session :current_account,
      on_mount: [
        {CoreWeb.AccountAuthenticationHelpers, :mount_current_account}
      ] do
      live "/", CoreWeb.PageLive, :home
      live "/socials", CoreWeb.PageLive, :socials
      live "/discord", CoreWeb.PageLive, :discord
      live "/about", CoreWeb.PageLive, :about
      live "/contact", CoreWeb.PageLive, :contact
      live "/accounts/confirm/:token", CoreWeb.AccountConfirmationLive, :edit
      live "/accounts/confirm", CoreWeb.AccountConfirmationInstructionsLive, :new
    end

    scope "/halls" do
      pipe_through [:set_namespace]

      live_session :current_account_for_halls,
        on_mount: [
          {CoreWeb.AccountAuthenticationHelpers, :mount_current_account},
          {CoreWeb.Plugs.Namespace, :set_namespace}
        ] do
        live "/", CoreWeb.HallLive, :list
        live "/:id", CoreWeb.HallLive, :show
        live "/:hall_id/nominations/", CoreWeb.NominationLive, :list
        live "/:hall_id/votes/", CoreWeb.VoteLive, :list
      end
    end

    scope "/lop" do
      pipe_through [:set_namespace]

      live_session :current_account_for_lop,
        on_mount: [
          {CoreWeb.AccountAuthenticationHelpers, :mount_current_account},
          {CoreWeb.Plugs.Namespace, :set_namespace}
        ] do
        live "/", CoreWeb.GameplayLive, :lop
        live "/conferences/:id", CoreWeb.ConferenceLive, :show
        live "/divisions/:id", CoreWeb.DivisionLive, :show
        live "/seasons/:id", CoreWeb.SeasonLive, :show
        live "/seasons", CoreWeb.SeasonLive, :list
        live "/plants/:id", CoreWeb.PlantLive, :show
        live "/plants", CoreWeb.PlantLive, :list
        live "/champions/:id", CoreWeb.ChampionLive, :show
        live "/champions/", CoreWeb.ChampionLive, :list
        # live "/conferences/", CoreWeb.CardLive, :list
        # live "/conferences/:id", CoreWeb.CardLive, :show
        # live "/divisions/", CoreWeb.CardLive, :list
        # live "/divisions/:id", CoreWeb.CardLive, :show
        live "/matches/", CoreWeb.MatchLive, :list
        live "/matches/:id", CoreWeb.MatchLive, :show
      end
    end
  end

  scope "/admin", as: :admin do
    pipe_through [
      :browser,
      :require_authenticated_account,
      :set_namespace,
      :require_administrative_privilages
    ]

    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    live_dashboard "/phoenix", metrics: CoreWeb.Telemetry

    live_session :admin,
      on_mount: [
        {CoreWeb.AccountAuthenticationHelpers, :ensure_authenticated},
        {CoreWeb.Plugs.Namespace, :set_namespace},
        {CoreWeb.Plugs.Administration, :require_administrative_privilages}
      ] do
      live "/", CoreWeb.AdminPageLive, :dashboard
      live "/jobs/:id", CoreWeb.JobLive, :show
      live "/jobs", CoreWeb.JobLive, :list
      live "/webhooks/:id", CoreWeb.WebhookLive, :show
      live "/webhooks", CoreWeb.WebhookLive, :list
      live "/rarities/:id", CoreWeb.RarityLive, :show
      live "/rarities", CoreWeb.RarityLive, :list
      live "/organizations/:id", CoreWeb.OrganizationLive, :show
      live "/organizations", CoreWeb.OrganizationLive, :list
      live "/accounts/:id", CoreWeb.AccountLive, :show
      live "/accounts", CoreWeb.AccountLive, :list

      scope "/lop" do
        live "/plants/:id/edit", CoreWeb.PlantLive, :edit
      end
    end
  end

  scope "/" do
    pipe_through [:browser, :require_authenticated_account]

    live_session :require_authenticated_account,
      on_mount: [
        {CoreWeb.AccountAuthenticationHelpers, :ensure_authenticated},
        {CoreWeb.Plugs.Namespace, :set_namespace}
      ] do
      scope "/lop" do
        pipe_through [:set_namespace]
        live "/packs/", CoreWeb.PackLive, :list
        live "/packs/:id", CoreWeb.PackLive, :show
        live "/cards/", CoreWeb.CardLive, :list
        live "/cards/:id", CoreWeb.CardLive, :show
      end

      live "/accounts/settings", CoreWeb.AccountSettingsLive, :edit
      live "/accounts/settings/confirm_email/:token", CoreWeb.AccountSettingsLive, :confirm_email
    end
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:core, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
