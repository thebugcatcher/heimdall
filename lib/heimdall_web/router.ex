defmodule HeimdallWeb.Router do
  use HeimdallWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HeimdallWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RemoteIp
  end

  pipeline :admin_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HeimdallWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RemoteIp
    plug :admin_auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HeimdallWeb do
    pipe_through :browser

    get "/", SecretController, :new

    post "/secrets", SecretController, :create

    get "/successfully_created", SecretController, :successfully_created

    get "/secrets/:secret_id", SecretController, :show

    get "/secret_404", SecretController, :secret_404
  end

  scope "/admin", HeimdallWeb.Admin do
    pipe_through :admin_browser

    get "/", DashboardController, :index
  end

  scope "/api", HeimdallWeb.API do
    pipe_through :api

    get "/health", HealthController, :index
  end

  if Application.compile_env(:heimdall, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HeimdallWeb.Telemetry
    end
  end

  @doc """
  Plug to add admin-related basic auth
  """
  @spec admin_auth(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def admin_auth(conn, _params) do
    Plug.BasicAuth.basic_auth(
      conn,
      username: admin_user(),
      password: admin_password()
    )
  end

  defp admin_user do
    Application.get_env(:heimdall, :admin_user)
  end

  defp admin_password do
    Application.get_env(:heimdall, :admin_password)
  end
end
