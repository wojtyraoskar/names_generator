defmodule PhoenixApi.Fixtures do
  @moduledoc """
  This module provides helper functions for creating test fixtures.
  """

  @doc """
  A helper function to create random names for testing.
  """
  def random_name(attrs \\ %{}) do
    {:ok, random_name} =
      %{
        first_name: "Test",
        last_name: "User",
        birthdate: ~D[1990-01-01],
        gender: :male
      }
      |> Map.merge(attrs)
      |> then(&PhoenixApi.RandomNames.RandomName.changeset(%PhoenixApi.RandomNames.RandomName{}, &1))
      |> PhoenixApi.Repo.insert()

    random_name
  end
end
