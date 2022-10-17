defmodule CoreWeb.Router do
  use CoreWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CoreWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_account
    plug CoreWeb.Plugs.Admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CoreWeb do
    pipe_through [:browser, :redirect_if_account_is_authenticated]

    get "/accounts/register", AccountRegistrationController, :new
    post "/accounts/register", AccountRegistrationController, :create
    get "/accounts/log_in", AccountSessionController, :new
    post "/accounts/log_in", AccountSessionController, :create
    get "/accounts/reset_password", AccountResetPasswordController, :new
    post "/accounts/reset_password", AccountResetPasswordController, :create
    get "/accounts/reset_password/:token", AccountResetPasswordController, :edit
    put "/accounts/reset_password/:token", AccountResetPasswordController, :update
  end

  scope "/", CoreWeb do
    pipe_through [:browser]

    live "/face", FaceLive, :index
    delete "/accounts/log_out", AccountSessionController, :delete
    get "/accounts/confirm", AccountConfirmationController, :new
    post "/accounts/confirm", AccountConfirmationController, :create
    get "/accounts/confirm/:token", AccountConfirmationController, :edit
    post "/accounts/confirm/:token", AccountConfirmationController, :update
    get "/", PageController, :index
    get "/about_us", PageController, :about_us
    get "/pricing", PageController, :pricing
    get "/faq", PageController, :faq
    delete "/accounts/log_out", AccountSessionController, :delete
    get "/accounts/confirm", AccountConfirmationController, :new
    post "/accounts/confirm", AccountConfirmationController, :create
    get "/accounts/confirm/:token", AccountConfirmationController, :edit
    post "/accounts/confirm/:token", AccountConfirmationController, :update
  end

  scope "/", CoreWeb do
    pipe_through [:browser, :require_authenticated_account]

    get "/accounts/settings", AccountSettingsController, :edit
    put "/accounts/settings", AccountSettingsController, :update

    get "/accounts/settings/confirm_email_address/:token",
        AccountSettingsController,
        :confirm_email_address
  end

  scope "/admin", as: :admin do
    pipe_through [:browser, :require_authenticated_account]

    live "/", CoreWeb.Live.AdminPage
    live "/jobs/:id", CoreWeb.Live.Job, :show
    live "/jobs", CoreWeb.Live.Job, :list
    live "/organizations/:id", CoreWeb.Live.Organization, :show
    live "/organizations", CoreWeb.Live.Organization, :list
    live "/accounts/:id", CoreWeb.Live.Account, :show
    live "/accounts", CoreWeb.Live.Account, :list
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/admin", as: :admin do
      pipe_through [:browser, :require_authenticated_account]

    live "/monsters", CoreWeb.Live.Monster.Index
    live "/monsters/:id", CoreWeb.Live.Monster.Show
    live "/cultural_arts", CoreWeb.Live.CulturalArt.Index
    live "/cultural_arts/:id", CoreWeb.Live.CulturalArt.Show
    live "/cultural_pillars", CoreWeb.Live.CulturalPillar.Index
    live "/cultural_pillars/:id", CoreWeb.Live.CulturalPillar.Show
    live "/cultural_ethoses", CoreWeb.Live.CulturalEthos.Index
    live "/cultural_ethoses/:id", CoreWeb.Live.CulturalEthos.Show
    live "/background_options", CoreWeb.Live.BackgroundOption.Index
    live "/background_options/:id", CoreWeb.Live.BackgroundOption.Show
    live "/archetypes", CoreWeb.Live.Archetype.Index
    live "/archetypes/:id", CoreWeb.Live.Archetype.Show
    live "/objective_options", CoreWeb.Live.ObjectiveOption.Index
    live "/objective_options/:id", CoreWeb.Live.ObjectiveOption.Show
    live "/trap_bait_options", CoreWeb.Live.TrapBaitOption.Index
    live "/trap_bait_options/:id", CoreWeb.Live.TrapBaitOption.Show
    live "/trap_effect_options", CoreWeb.Live.TrapEffectOption.Index
    live "/trap_effect_options/:id", CoreWeb.Live.TrapEffectOption.Show
    live "/trap_lethality_options", CoreWeb.Live.TrapLethalityOption.Index
    live "/trap_lethality_options/:id", CoreWeb.Live.TrapLethalityOption.Show
    live "/trap_location_options", CoreWeb.Live.TrapLocationOption.Index
    live "/trap_location_options/:id", CoreWeb.Live.TrapLocationOption.Show
    live "/trap_purpose_options", CoreWeb.Live.TrapPurposeOption.Index
    live "/trap_purpose_options/:id", CoreWeb.Live.TrapPurposeOption.Show
    live "/trap_reset_options", CoreWeb.Live.TrapResetOption.Index
    live "/trap_reset_options/:id", CoreWeb.Live.TrapResetOption.Show
    live "/trap_trigger_options", CoreWeb.Live.TrapTriggerOption.Index
    live "/trap_trigger_options/:id", CoreWeb.Live.TrapTriggerOption.Show
    live "/trap_type_options", CoreWeb.Live.TrapTypeOption.Index
    live "/trap_type_options/:id", CoreWeb.Live.TrapTypeOption.Show
    live "/accounts", CoreWeb.Live.Account.Index
    live "/accounts/:id", CoreWeb.Live.Account.Show

    # Enables the Swoosh mailbox preview in development.
    #
    # Note that preview only shows emails that were sent by the same
    # node running the Phoenix server.
    if Mix.env() == :dev do
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end

    # Enables LiveDashboard only for development
    #
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    unless Mix.env() == :prod do
      live_dashboard "/dashboard",
        metrics: CoreWeb.Telemetry,
        additional_pages: [
          profiler: {PhoenixProfiler.Dashboard, []},
          flame_on: FlameOn.DashboardPage,
          exceptions: Phoenix.LiveDashboard.Exceptions
        ]
    end

    if Mix.env() == :prod do
      live_dashboard "/dashboard",
        metrics: CoreWeb.Telemetry
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  scope "/admin", as: :admin do
    pipe_through [:browser, :require_authenticated_account]
    import Phoenix.LiveDashboard.Router

    live_dashboard "/phoenix",
      metrics: CoreWeb.Telemetry
  end
end
