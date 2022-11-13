defmodule CoreWeb.Router do
  use Phoenix.Router

  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.LiveView.Router
  import CoreWeb.AccountAuthenticationHelpers
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

    get "/", PageController, :index
    get "/socials", PageController, :socials
    get "/discord", PageController, :discord
    get "/about", PageController, :about
    get "/projects", PageController, :projects
    get "/contact", PageController, :contact
    live "/face", FaceLive, :index
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

      forward "/mailbox", Plug.Swoosh.MailboxPreview
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
