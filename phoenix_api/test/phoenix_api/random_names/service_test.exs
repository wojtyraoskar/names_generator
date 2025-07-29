defmodule PhoenixApi.RandomNames.ServiceTest do
  use PhoenixApi.DataCase, async: true

  alias PhoenixApi.RandomNames.Service
  import PhoenixApi.Fixtures

  describe "list_users/1" do
    test "returns empty list when no names exist" do
      {:ok, result} = Service.list_users(%{})
      assert result.data == []
      assert result.pagination.total_count == 0
      assert result.pagination.page == 1
      assert result.pagination.per_page == 20
    end

    test "returns all names when no filters provided" do
      _name1 = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", gender: :female})

      {:ok, result} = Service.list_users(%{})

      assert length(result.data) == 2
      assert result.pagination.total_count == 2
      assert result.pagination.page == 1
      assert result.pagination.per_page == 20
      assert result.pagination.total_pages == 1
      assert result.pagination.has_next == false
      assert result.pagination.has_prev == false
      assert Enum.any?(result.data, fn name -> name.first_name == "John" end)
      assert Enum.any?(result.data, fn name -> name.first_name == "Jane" end)
    end

    test "filters names by last_name with ilike search" do
      _name1 = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", gender: :female})
      _name3 = random_name(%{first_name: "Bob", last_name: "Doe", gender: :male})
      _name4 = random_name(%{first_name: "Alice", last_name: "Johnson", gender: :female})

      {:ok, result} = Service.list_users(%{last_name: "doe"})

      assert length(result.data) == 2
      assert result.pagination.total_count == 2
      assert Enum.all?(result.data, fn name -> String.contains?(String.downcase(name.last_name), "doe") end)
    end

    test "filters names by first_name with ilike search" do
      _name1 = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", gender: :female})
      _name3 = random_name(%{first_name: "Johnson", last_name: "Brown", gender: :male})
      _name4 = random_name(%{first_name: "Alice", last_name: "Johnson", gender: :female})

      {:ok, result} = Service.list_users(%{first_name: "john"})

      assert length(result.data) == 2
      assert result.pagination.total_count == 2
      assert Enum.all?(result.data, fn name -> String.contains?(String.downcase(name.first_name), "john") end)
    end

    test "filters names by birthdate" do
      date1 = ~D[1990-01-15]
      date2 = ~D[1995-03-20]
      date3 = ~D[1990-01-15]

      _name1 = random_name(%{first_name: "John", last_name: "Doe", birthdate: date1, gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", birthdate: date2, gender: :female})
      _name3 = random_name(%{first_name: "Bob", last_name: "Brown", birthdate: date3, gender: :male})

      {:ok, result} = Service.list_users(%{birthdate: date1})

      assert length(result.data) == 2
      assert result.pagination.total_count == 2
      assert Enum.all?(result.data, fn name -> name.birthdate == date1 end)
    end

    test "filters names by birthdate_from" do
      date1 = ~D[1990-01-15]
      date2 = ~D[1995-03-20]
      date3 = ~D[2000-06-10]
      date4 = ~D[1985-12-25]

      _name1 = random_name(%{first_name: "John", last_name: "Doe", birthdate: date1, gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", birthdate: date2, gender: :female})
      _name3 = random_name(%{first_name: "Bob", last_name: "Brown", birthdate: date3, gender: :male})
      _name4 = random_name(%{first_name: "Alice", last_name: "Johnson", birthdate: date4, gender: :female})

      {:ok, result} = Service.list_users(%{birthdate_from: ~D[1990-01-01]})

      assert length(result.data) == 3
      assert result.pagination.total_count == 3
      assert Enum.all?(result.data, fn name -> Date.compare(name.birthdate, ~D[1990-01-01]) in [:gt, :eq] end)
    end

    test "filters names by birthdate_to" do
      date1 = ~D[1990-01-15]
      date2 = ~D[1995-03-20]
      date3 = ~D[2000-06-10]
      date4 = ~D[1985-12-25]

      _name1 = random_name(%{first_name: "John", last_name: "Doe", birthdate: date1, gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", birthdate: date2, gender: :female})
      _name3 = random_name(%{first_name: "Bob", last_name: "Brown", birthdate: date3, gender: :male})
      _name4 = random_name(%{first_name: "Alice", last_name: "Johnson", birthdate: date4, gender: :female})

      {:ok, result} = Service.list_users(%{birthdate_to: ~D[1995-12-31]})

      assert length(result.data) == 3
      assert result.pagination.total_count == 3
      assert Enum.all?(result.data, fn name -> Date.compare(name.birthdate, ~D[1995-12-31]) in [:lt, :eq] end)
    end

    test "filters names by birthdate range (from and to)" do
      date1 = ~D[1990-01-15]
      date2 = ~D[1995-03-20]
      date3 = ~D[2000-06-10]
      date4 = ~D[1985-12-25]
      date5 = ~D[1992-08-15]

      _name1 = random_name(%{first_name: "John", last_name: "Doe", birthdate: date1, gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", birthdate: date2, gender: :female})
      _name3 = random_name(%{first_name: "Bob", last_name: "Brown", birthdate: date3, gender: :male})
      _name4 = random_name(%{first_name: "Alice", last_name: "Johnson", birthdate: date4, gender: :female})
      _name5 = random_name(%{first_name: "Charlie", last_name: "Wilson", birthdate: date5, gender: :male})

      {:ok, result} = Service.list_users(%{birthdate_from: ~D[1990-01-01], birthdate_to: ~D[1995-12-31]})

      assert length(result.data) == 3
      assert result.pagination.total_count == 3

      assert Enum.all?(result.data, fn name ->
               Date.compare(name.birthdate, ~D[1990-01-01]) in [:gt, :eq] and
                 Date.compare(name.birthdate, ~D[1995-12-31]) in [:lt, :eq]
             end)
    end

    test "filters names by gender" do
      _name1 = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", gender: :female})
      _name3 = random_name(%{first_name: "Bob", last_name: "Brown", gender: :male})
      _name4 = random_name(%{first_name: "Alice", last_name: "Johnson", gender: :female})

      {:ok, result} = Service.list_users(%{gender: :male})

      assert length(result.data) == 2
      assert result.pagination.total_count == 2
      assert Enum.all?(result.data, fn name -> name.gender == :male end)
    end

    test "filters names by combination of first_name and gender" do
      _name1 = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", gender: :female})
      _name3 = random_name(%{first_name: "Johnson", last_name: "Brown", gender: :male})
      _name4 = random_name(%{first_name: "Alice", last_name: "Johnson", gender: :female})
      _name5 = random_name(%{first_name: "Johnny", last_name: "Wilson", gender: :male})

      {:ok, result} = Service.list_users(%{first_name: "john", gender: :male})

      assert length(result.data) == 3
      assert result.pagination.total_count == 3

      assert Enum.all?(result.data, fn name ->
               String.contains?(String.downcase(name.first_name), "john") and name.gender == :male
             end)
    end

    test "filters names using string keys" do
      _name1 = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", gender: :female})
      _name3 = random_name(%{first_name: "Bob", last_name: "Doe", gender: :male})

      {:ok, result} = Service.list_users(%{"last_name" => "doe"})

      assert length(result.data) == 2
      assert result.pagination.total_count == 2
      assert Enum.all?(result.data, fn name -> String.contains?(String.downcase(name.last_name), "doe") end)
    end

    test "filters names using string keys for birthdate range" do
      date1 = ~D[1990-01-15]
      date2 = ~D[1995-03-20]
      date3 = ~D[2000-06-10]

      _name1 = random_name(%{first_name: "John", last_name: "Doe", birthdate: date1, gender: :male})
      _name2 = random_name(%{first_name: "Jane", last_name: "Smith", birthdate: date2, gender: :female})
      _name3 = random_name(%{first_name: "Bob", last_name: "Brown", birthdate: date3, gender: :male})

      {:ok, result} = Service.list_users(%{"birthdate_from" => "1990-01-01", "birthdate_to" => "1995-12-31"})

      assert length(result.data) == 2
      assert result.pagination.total_count == 2

      assert Enum.all?(result.data, fn name ->
               Date.compare(name.birthdate, ~D[1990-01-01]) in [:gt, :eq] and
                 Date.compare(name.birthdate, ~D[1995-12-31]) in [:lt, :eq]
             end)
    end

    test "supports pagination with custom page and per_page" do
      # Create 25 users to test pagination
      for i <- 1..25 do
        random_name(%{first_name: "User#{i}", last_name: "Test#{i}", gender: :male})
      end

      {:ok, result} = Service.list_users(%{page: 2, per_page: 10})

      assert length(result.data) == 10
      assert result.pagination.page == 2
      assert result.pagination.per_page == 10
      assert result.pagination.total_count == 25
      assert result.pagination.total_pages == 3
      assert result.pagination.has_next == true
      assert result.pagination.has_prev == true
    end

    test "handles pagination on first page" do
      # Create 15 users
      for i <- 1..15 do
        random_name(%{first_name: "User#{i}", last_name: "Test#{i}", gender: :male})
      end

      {:ok, result} = Service.list_users(%{page: 1, per_page: 10})

      assert length(result.data) == 10
      assert result.pagination.page == 1
      assert result.pagination.per_page == 10
      assert result.pagination.total_count == 15
      assert result.pagination.total_pages == 2
      assert result.pagination.has_next == true
      assert result.pagination.has_prev == false
    end

    test "handles pagination on last page" do
      # Create 15 users
      for i <- 1..15 do
        random_name(%{first_name: "User#{i}", last_name: "Test#{i}", gender: :male})
      end

      {:ok, result} = Service.list_users(%{page: 2, per_page: 10})

      assert length(result.data) == 5
      assert result.pagination.page == 2
      assert result.pagination.per_page == 10
      assert result.pagination.total_count == 15
      assert result.pagination.total_pages == 2
      assert result.pagination.has_next == false
      assert result.pagination.has_prev == true
    end

    test "combines pagination with filters" do
      # Create users with different genders
      for i <- 1..10 do
        random_name(%{first_name: "Male#{i}", last_name: "Test", gender: :male})
      end

      for i <- 1..5 do
        random_name(%{first_name: "Female#{i}", last_name: "Test", gender: :female})
      end

      {:ok, result} = Service.list_users(%{gender: :male, page: 2, per_page: 3})

      assert length(result.data) == 3
      assert result.pagination.total_count == 10
      assert result.pagination.page == 2
      assert result.pagination.per_page == 3
      assert result.pagination.total_pages == 4
      assert Enum.all?(result.data, fn name -> name.gender == :male end)
    end

    test "combines birthdate range filtering with pagination" do
      # Create users with different birthdates
      for i <- 1..10 do
        year = 1990 + i
        random_name(%{first_name: "User#{i}", last_name: "Test", birthdate: Date.new!(year, 1, 1), gender: :male})
      end

      for i <- 1..5 do
        year = 2000 + i
        random_name(%{first_name: "User#{i + 10}", last_name: "Test", birthdate: Date.new!(year, 1, 1), gender: :male})
      end

      {:ok, result} =
        Service.list_users(%{birthdate_from: ~D[1995-01-01], birthdate_to: ~D[1999-12-31], page: 2, per_page: 3})

      assert length(result.data) == 2
      assert result.pagination.total_count == 5
      assert result.pagination.page == 2
      assert result.pagination.per_page == 3
      assert result.pagination.total_pages == 2

      assert Enum.all?(result.data, fn name ->
               Date.compare(name.birthdate, ~D[1995-01-01]) in [:gt, :eq] and
                 Date.compare(name.birthdate, ~D[1999-12-31]) in [:lt, :eq]
             end)
    end
  end

  describe "get_user/1" do
    test "returns user when found" do
      user = random_name(%{first_name: "John", last_name: "Doe", gender: :male})

      result = Service.get_user(user.id)

      assert {:ok, found_user} = result
      assert found_user.id == user.id
      assert found_user.first_name == "John"
      assert found_user.last_name == "Doe"
      assert found_user.gender == :male
    end

    test "returns error when user not found" do
      result = Service.get_user(999)

      assert {:error, "User not found"} = result
    end
  end

  describe "create_user/1" do
    test "creates user with valid attributes" do
      attrs = %{
        first_name: "Alice",
        last_name: "Johnson",
        birthdate: ~D[1990-05-15],
        gender: :female
      }

      result = Service.create_user(attrs)

      assert {:ok, user} = result
      assert user.first_name == "Alice"
      assert user.last_name == "Johnson"
      assert user.birthdate == ~D[1990-05-15]
      assert user.gender == :female
      assert user.id
    end

    test "returns error with invalid attributes" do
      attrs = %{first_name: "", last_name: "Doe", gender: :male}

      result = Service.create_user(attrs)

      assert {:error, error_message} = result
      assert String.contains?(error_message, "Failed to create user")
    end
  end

  describe "update_user/2" do
    test "updates user with valid attributes" do
      user = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      update_attrs = %{first_name: "Jane", last_name: "Smith"}

      result = Service.update_user(user.id, update_attrs)

      assert {:ok, updated_user} = result
      assert updated_user.id == user.id
      assert updated_user.first_name == "Jane"
      assert updated_user.last_name == "Smith"
      # unchanged
      assert updated_user.gender == :male
    end

    test "returns error when user not found" do
      result = Service.update_user(999, %{first_name: "Jane"})

      assert {:error, "User not found"} = result
    end

    test "returns error with invalid attributes" do
      user = random_name(%{first_name: "John", last_name: "Doe", gender: :male})
      invalid_attrs = %{first_name: ""}

      result = Service.update_user(user.id, invalid_attrs)

      assert {:error, error_message} = result
      assert String.contains?(error_message, "Failed to update user")
    end
  end

  describe "delete_user/1" do
    test "deletes user when found" do
      user = random_name(%{first_name: "John", last_name: "Doe", gender: :male})

      result = Service.delete_user(user.id)

      assert {:ok, deleted_user} = result
      assert deleted_user.id == user.id
      assert deleted_user.first_name == "John"
    end

    test "returns error when user not found" do
      result = Service.delete_user(999)

      assert {:error, "User not found"} = result
    end
  end
end
