defmodule PhoenixApi.GovData.NamesBaseOnPesel do
  @callback fetch_female_names() :: {:ok, list()} | {:error, any()}
  @callback fetch_male_names() :: {:ok, list()} | {:error, any()}
  @callback fetch_female_lastnames() :: {:ok, list()} | {:error, any()}
  @callback fetch_male_lastnames() :: {:ok, list()} | {:error, any()}

  @adapter Application.compile_env(:phoenix_api, [:adapters, __MODULE__], __MODULE__.Adapter.Http)

  defdelegate fetch_female_names(), to: @adapter

  defdelegate fetch_male_names(), to: @adapter

  defdelegate fetch_female_lastnames(), to: @adapter

  defdelegate fetch_male_lastnames(), to: @adapter
end
