defmodule BookclubWeb.Router do
  use BookclubWeb, :router

  # use Plug.ErrorHandler
  # use Sentry.Plug

  @admin_pipeline [:browser, :auth, :ensure_admin]
  @regular_user_pipeline [:auth, :ensure_auth, :ensure_regular]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug Bookclub.Auth.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :ensure_admin do
    plug Bookclub.Auth.UserType, :admin
  end

  pipeline :ensure_regular do
    plug Bookclub.Auth.UserType, :regular
  end

  scope "/", BookclubWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/chat", ChatRoomController, :index
    get "/join/:club_id/:join_code", ClubMemberController, :new
    get "/reset_password/:id/:reset_token", PageController, :reset_password
  end

  scope "/login", BookclubWeb.Admin, as: :admin do
    pipe_through :browser

    get "/signin", LoginController, :show
    get "/signout", LoginController, :signout
    post "/signin", LoginController, :signin
  end

  scope "/admin", BookclubWeb.Admin, as: :admin do
    pipe_through @admin_pipeline

    get "/", DashBoardController, :index
    resources "/users", UserController
    resources "/clubs", ClubController
  end

  scope "/api", BookclubWeb, as: :api do
    pipe_through :api

    scope "/accounts" do
      get "/authenticate/:token", AccountController, :authenticate
      post "/signup", AccountController, :signup
      post "/signin", AccountController, :signin
      post "/signout", AccountController, :signout

      post "/password_reset/issue", AccountPasswordResetController, :issue
      post "/password_reset/check_token", AccountPasswordResetController, :check_token
      post "/password_reset", AccountPasswordResetController, :reset

      pipe_through @regular_user_pipeline

      get "/", AccountController, :my_account
      get "/profile/:user_id", AccountController, :show

      post "/add_expo_push_token", AccountController, :add_expo_push_token
      post "/remove_expo_push_token", AccountController, :remove_expo_push_token

      post "/metadata", AccountController, :write_metadata
    end

    scope "/clubs" do
      pipe_through @regular_user_pipeline

      post "/", ClubController, :create
      get "/", ClubController, :index
      post "/:club_id/join", ClubMemberController, :create
      delete "/:club_id/join", ClubMemberController, :destroy

      get "/:club_id/chat_info", ChatInfoController, :show
    end
  end

  scope "/.well-known", BookclubWeb, as: :external_verification do
    pipe_through :api

    get "/assetlinks.json", ExternalVerificationController, :android_association
    get "/apple-app-site-association", ExternalVerificationController, :ios_association
  end

  scope "/", BookclubWeb do
    match(:*, "/*path", CatchAllController, :index)
  end
end
