defmodule PhoenixApi.HTTPClient do
  @callback get(String.t()) :: {:ok, %{body: String.t()}} | {:error, any()}
end
