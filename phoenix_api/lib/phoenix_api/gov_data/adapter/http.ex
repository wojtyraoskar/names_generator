defmodule PhoenixApi.GovData.NamesBaseOnPesel.Adapter.Http do
  @behaviour PhoenixApi.GovData.NamesBaseOnPesel
  alias PhoenixApi.CSVProcessor, as: CSV

  # TODO: Place url in config / make sure that url can be configured

  def fetch_female_names() do
    fetch_data(
      "https://api.dane.gov.pl/resources/63924,lista-imion-zenskich-w-rejestrze-pesel-stan-na-22012025-imie-pierwsze/csv"
    )
  end

  def fetch_male_names() do
    fetch_data(
      "https://api.dane.gov.pl/resources/63916,lista-imion-meskich-w-rejestrze-pesel-stan-na-22012025-imie-pierwsze/csv"
    )
  end

  def fetch_female_lastnames() do
    fetch_data("https://api.dane.gov.pl/resources/63888,nazwiska-zenskie-stan-na-2025-01-22/csv")
  end

  def fetch_male_lastnames() do
    fetch_data("https://api.dane.gov.pl/resources/63892,nazwiska-meskie-stan-na-2025-01-22/csv")
  end

  defp fetch_data(url) do
    http_client = Application.get_env(:phoenix_api, :http_client, HTTPoison)

    case http_client.get(url, [], follow_redirect: true) do
      {:ok, %{body: body}} ->
        {:ok,
         body
         |> CSV.parse_string()
         |> Enum.map(&List.first/1)}

      {:error, _reason} ->
        {:error, "Failed to download data from #{url}"}
    end
  end
end
