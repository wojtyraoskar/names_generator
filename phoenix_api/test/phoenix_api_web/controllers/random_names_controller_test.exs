defmodule PhoenixApiWeb.RandomNamesControllerTest do
  use PhoenixApiWeb.ConnCase, async: true

  import PhoenixApi.Fixtures

  describe "index" do
    test "GET /api/users returns list of users", %{conn: conn} do
      _user = random_name(%{first_name: "John", last_name: "Doe", gender: :male})

      conn = get(conn, ~p"/api/users")

      response = json_response(conn, 200)
      assert is_list(response["data"])
    end

    test "GET /api/users with pagination parameters returns paginated results", %{conn: conn} do
      # Create multiple users to test pagination
      Enum.each(1..25, fn i ->
        random_name(%{first_name: "User#{i}", last_name: "Test", gender: :male})
      end)

      conn = get(conn, ~p"/api/users?page=2&per_page=10")

      response = json_response(conn, 200)
      assert is_list(response["data"])
      assert length(response["data"]) <= 10
      assert response["pagination"]["page"] == 2
      assert response["pagination"]["per_page"] == 10
      assert response["pagination"]["total_count"] >= 25
      assert response["pagination"]["has_next"] == true
      assert response["pagination"]["has_prev"] == true
    end

    test "GET /api/users with filtering parameters returns filtered results", %{conn: conn} do
      # Create users with different names
      _user1 = random_name(%{first_name: "Alice", last_name: "Johnson", gender: :female})
      _user2 = random_name(%{first_name: "Bob", last_name: "Smith", gender: :male})
      _user3 = random_name(%{first_name: "Charlie", last_name: "Brown", gender: :male})

      conn = get(conn, ~p"/api/users?first_name=Alice&gender=female")

      response = json_response(conn, 200)
      assert is_list(response["data"])

      # Should only return users with first_name containing "Alice" and gender female
      Enum.each(response["data"], fn user ->
        assert String.contains?(user["first_name"], "Alice")
        assert user["gender"] == "female"
      end)
    end
  end

  describe "show" do
    test "GET /api/users/:id returns user when found", %{conn: conn} do
      user = random_name(%{first_name: "John", last_name: "Doe", gender: :male})

      conn = get(conn, ~p"/api/users/#{user.id}")

      response = json_response(conn, 200)
      assert response["id"] == user.id
      assert response["first_name"] == "John"
      assert response["last_name"] == "Doe"
      assert response["gender"] == "male"
    end
  end

  describe "create" do
    test "POST /api/users creates user", %{conn: conn} do
      user_attrs = %{
        "first_name" => "Alice",
        "last_name" => "Johnson",
        "birthdate" => "1990-05-15",
        "gender" => "female"
      }

      conn = post(conn, ~p"/api/users", user_attrs)

      response = json_response(conn, 201)
      assert response["first_name"] == "Alice"
    end
  end

  describe "update" do
    test "PUT /api/users/:id updates user", %{conn: conn} do
      user = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      update_attrs = %{"first_name" => "Jane"}

      conn = put(conn, ~p"/api/users/#{user.id}", update_attrs)

      response = json_response(conn, 200)
      assert response["first_name"] == "Jane"
    end
  end

  describe "delete" do
    test "DELETE /api/users/:id deletes user", %{conn: conn} do
      user = random_name(%{first_name: "John", last_name: "Doe", gender: :male})

      conn = delete(conn, ~p"/api/users/#{user.id}")

      assert response(conn, 204)
    end
  end

  describe "import" do
    test "POST /api/import successfully imports names", %{conn: conn} do
      conn = post(conn, ~p"/api/import")

      response = json_response(conn, 201)
      assert response["message"] =~ "Successfully imported"
      assert is_integer(response["count"])
      assert response["count"] > 0
    end
  end
end
