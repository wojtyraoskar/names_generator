defmodule PhoenixApi.Names.Command.ImportNamesTest do
  use PhoenixApi.DataCase, async: true

  alias PhoenixApi.Repo
  alias PhoenixApi.RandomNames.Command.ImportNames, as: Subject
  alias PhoenixApi.RandomNames.RandomName

  describe "call/0" do
    test "downloads and processes names and lastnames correctly" do
      Subject.call()

      assert Repo.all(RandomName) |> length() == 100

      Subject.call()

      assert Repo.all(RandomName) |> length() == 200
    end

    test "generates valid user data with proper structure" do
      Subject.call()

      users = Repo.all(RandomName)
      assert length(users) == 100

      # Check that all users have required fields
      for user <- users do
        assert is_binary(user.first_name)
        assert is_binary(user.last_name)
        assert user.gender in [:male, :female]
        assert is_struct(user.birthdate, Date)
        assert not is_nil(user.inserted_at)
        assert not is_nil(user.updated_at)
      end
    end

    test "generates users with both genders" do
      Subject.call()

      users = Repo.all(RandomName)
      male_count = Enum.count(users, &(&1.gender == :male))
      female_count = Enum.count(users, &(&1.gender == :female))

      assert male_count > 0, "Should generate some male users"
      assert female_count > 0, "Should generate some female users"
      assert male_count + female_count == 100
    end
  end

  describe "generate_users_by_gender/4" do
    test "generates correct number of users" do
      first_names = ["Alice", "Bob", "Charlie"]
      last_names = ["Smith", "Johnson", "Williams"]
      gender = "female"
      count = 5

      users = Subject.generate_users_by_gender(first_names, last_names, gender, count)

      assert length(users) == count
    end

    test "generates random names from provided lists" do
      first_names = ["Alice", "Bob"]
      last_names = ["Smith", "Johnson"]
      gender = "female"
      count = 10

      users = Subject.generate_users_by_gender(first_names, last_names, gender, count)

      # Check that we get some variety in the random selection
      unique_first_names = users |> Enum.map(& &1.first_name) |> Enum.uniq()
      unique_last_names = users |> Enum.map(& &1.last_name) |> Enum.uniq()

      assert length(unique_first_names) > 1, "Should generate variety in first names"
      assert length(unique_last_names) > 1, "Should generate variety in last names"
    end

    test "handles single name in lists" do
      first_names = ["Alice"]
      last_names = ["Smith"]
      gender = "male"
      count = 5

      users = Subject.generate_users_by_gender(first_names, last_names, gender, count)

      assert length(users) == count

      for user <- users do
        assert user.first_name == "Alice"
        assert user.last_name == "Smith"
        assert user.gender == :male
      end
    end
  end
end
