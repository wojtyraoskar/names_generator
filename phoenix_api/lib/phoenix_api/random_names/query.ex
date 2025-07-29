defmodule PhoenixApi.RandomNames.Query do
  use PhoenixApi.Query

  contract do
    field :first_name, :string
    field :last_name, :string
    field :birthdate, :date
    field :gender, Ecto.Enum, values: [:male, :female]
    field :page, :integer, default: 1
    field :per_page, :integer, default: 20
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

  defp apply_filter(query, %Q{page: page, per_page: per_page}, :page) do
    offset = (page - 1) * per_page

    query
    |> limit(^per_page)
    |> offset(^offset)
  end

  defp apply_filter(query, %Q{per_page: _per_page}, :per_page) do
    # per_page is handled in the page filter
    query
  end

  defp apply_filter(query, _, _), do: query

  def base_query, do: PhoenixApi.RandomNames.RandomName
end
