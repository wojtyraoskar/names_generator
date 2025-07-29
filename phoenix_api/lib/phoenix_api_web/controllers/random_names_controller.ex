defmodule PhoenixApiWeb.RandomNamesController do
  use PhoenixApiWeb, :controller

  alias PhoenixApi.RandomNames.Service

  action_fallback PhoenixApiWeb.FallbackController

  # TODO: Add Swagger

  def index(conn, params) do
    with {:ok, result} <- Service.list_users(params) do
      conn
      |> put_status(:ok)
      |> json(result)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Service.get_user(id) do
      conn
      |> put_status(:ok)
      |> json(user)
    end
  end

  def create(conn, params) do
    with {:ok, user} <- Service.create_user(params) do
      conn
      |> put_status(:created)
      |> json(user)
    end
  end

  def update(conn, %{"id" => id} = params) do
    attrs = Map.delete(params, "id")

    with {:ok, user} <- Service.update_user(id, attrs) do
      conn
      |> put_status(:ok)
      |> json(user)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, _user} <- Service.delete_user(id) do
      conn
      |> put_status(:no_content)
      |> send_resp(204, "")
    end
  end
end
