defmodule PhoenixApi.RandomNames.Command.ImportNames do
  @moduledoc """
  TODO: Add oban worker to import names from gov data. This could fail especially if the data is not available.
  """
  alias PhoenixApi.Repo
  alias PhoenixApi.GovData.NamesBaseOnPesel

  @date_range {~D[1970-01-01], ~D[2024-12-31]}

  def call do
    with {:ok, female_first_names} <- NamesBaseOnPesel.fetch_female_names(),
         {:ok, male_first_names} <- NamesBaseOnPesel.fetch_male_names(),
         {:ok, female_last_names} <- NamesBaseOnPesel.fetch_female_lastnames(),
         {:ok, male_last_names} <- NamesBaseOnPesel.fetch_male_lastnames(),
         female_users <- generate_users_by_gender(female_first_names, female_last_names, "female", 100),
         male_users <- generate_users_by_gender(male_first_names, male_last_names, "male", 100),
         final_users <- Enum.take_random(female_users ++ male_users, 100),
         # TODO: Insert should be take out from here and place in Repo for Names
         {count, _} when is_number(count) <- Repo.insert_all(PhoenixApi.RandomNames.RandomName, final_users) do
      {:ok, count}
    else
      error ->
        {:error, "Failed to fetch names data: #{inspect(error)}"}
    end
  end

  def generate_users_by_gender(first_names, last_names, gender, count) do
    for _ <- 1..count do
      # TODO: Cast on names struct with validation
      %{
        first_name: Enum.random(first_names),
        last_name: Enum.random(last_names),
        gender: String.to_atom(gender),
        birthdate: random_date(@date_range),
        inserted_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second),
        updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      }
    end
  end

  defp random_date({from, to}) do
    days = Date.diff(to, from)
    Date.add(from, Enum.random(0..days))
  end
end
