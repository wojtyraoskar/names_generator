defmodule PhoenixApiWeb.HealthController do
  use PhoenixApiWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{
      status: "healthy",
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
      application: "phoenix_api",
      version: "0.1.0"
    })
  end
end
