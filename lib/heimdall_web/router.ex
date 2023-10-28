defmodule HeimdallWeb.Router do
  use HeimdallWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HeimdallWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
end
