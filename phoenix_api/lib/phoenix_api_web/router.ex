defmodule PhoenixApiWeb.Router do
  use PhoenixApiWeb, :router

  pipeline :api do
    # add plug for auth eatche for user token of api key
    plug :accepts, ["json"]
  end

  scope "/api", PhoenixApiWeb do
    pipe_through :api

    get "/health", HealthController, :index

    # Random Names API endpoints
    resources "/users", RandomNamesController, only: [:index, :show, :create, :update, :delete]
    post "/import", RandomNamesController, :import
  end

  if Application.compile_env(:phoenix_api, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: PhoenixApiWeb.Telemetry
    end
  end
end
