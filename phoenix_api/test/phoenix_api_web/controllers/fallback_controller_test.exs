defmodule PhoenixApiWeb.FallbackControllerTest do
  use PhoenixApiWeb.ConnCase, async: true

  describe "call/2" do
    test "handles not found error", %{conn: conn} do
      conn = PhoenixApiWeb.FallbackController.call(conn, {:error, :not_found})

      response = json_response(conn, 404)
      assert response["error"] == "Not found"
    end

    test "handles string error message", %{conn: conn} do
      conn = PhoenixApiWeb.FallbackController.call(conn, {:error, "Something went wrong"})

      response = json_response(conn, 422)
      assert response["error"] == "Something went wrong"
    end

    test "handles unauthorized error", %{conn: conn} do
      conn = PhoenixApiWeb.FallbackController.call(conn, {:error, :unauthorized})

      response = json_response(conn, 401)
      assert response["error"] == "Unauthorized"
    end
  end
end
