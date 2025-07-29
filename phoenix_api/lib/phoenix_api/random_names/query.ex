defmodule PhoenixApi.RandomNames.Query do
  use PhoenixApi.Query

  contract do
    field :first_name, :string
    field :last_name, :string
    field :birthdate, :date
    field :gender, Ecto.Enum, values: [:male, :female]
  end

  defp apply_filter(query, %Q{first_name: value}, :first_name) do
    query
    |> where([r0], ilike(r0.first_name, ^"%#{value}%"))
  end

  defp apply_filter(query, %Q{last_name: value}, :last_name) do
    query
    |> where([r0], ilike(r0.last_name, ^"%#{value}%"))
  end

  defp apply_filter(query, %Q{birthdate: value}, :birthdate) do
    query
    |> where([r0], r0.birthdate == ^value)
  end

  defp apply_filter(query, %Q{gender: value}, :gender) do
    query
    |> where([r0], r0.gender == ^value)
  end

  defp apply_filter(query, _, _), do: query

  def base_query, do: PhoenixApi.RandomNames.RandomName
end
