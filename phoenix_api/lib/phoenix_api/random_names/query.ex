defmodule PhoenixApi.RandomNames.Query do
  use PhoenixApi.Query
  import Ecto.Query

  @text_filters [:first_name, :last_name]
  @sortable_fields [:first_name, :last_name, :birthdate, :gender, :id, :inserted_at, :updated_at]

  @default_sort_field :id
  @default_sort_dir :asc
  @max_per_page 100

  contract do
    field :first_name, :string
    field :last_name, :string
    field :birthdate, :date
    field :birthdate_from, :date
    field :birthdate_to, :date
    field :gender, Ecto.Enum, values: [:male, :female]
    field :page, :integer, default: 1
    field :per_page, :integer, default: 20
    field :sort, :string
  end

  def base_query, do: PhoenixApi.RandomNames.RandomName

  def build_count_query(%Q{} = struct) do
    __MODULE__.fields()
    |> Enum.reject(&(&1 in [:page, :per_page, :sort]))
    |> Enum.reduce(base_query(), fn field, query ->
      (struct |> Map.get(field) |> PhoenixApi.Infra.empty?() && query) ||
        apply_filter(query, struct, field)
    end)
    |> select([r], count(r.id))
  end

  defp apply_filter(query, %Q{} = q, field) when field in @text_filters do
    value = Map.fetch!(q, field)
    where(query, [r], ilike(field(r, ^field), ^"%#{value}%"))
  end

  defp apply_filter(query, %Q{birthdate: value}, :birthdate) do
    where(query, [r], r.birthdate == ^value)
  end

  defp apply_filter(query, %Q{birthdate_from: value}, :birthdate_from) do
    where(query, [r], r.birthdate >= ^value)
  end

  defp apply_filter(query, %Q{birthdate_to: value}, :birthdate_to) do
    where(query, [r], r.birthdate <= ^value)
  end

  defp apply_filter(query, %Q{gender: value}, :gender) do
    where(query, [r], r.gender == ^value)
  end

  defp apply_filter(query, %Q{page: page, per_page: per_page}, :page) do
    per_page = min(per_page || 20, @max_per_page)
    page = max(page || 1, 1)
    offset = (page - 1) * per_page

    query
    |> limit(^per_page)
    |> offset(^offset)
  end

  defp apply_filter(query, %Q{sort: sort_string}, :sort) do
    sort_string
    |> parse_sort_string()
    |> Enum.reduce(query, fn {field, dir}, acc -> apply_sort(acc, field, dir) end)
  end

  defp apply_filter(query, %Q{}, :per_page), do: query
  defp apply_filter(query, %Q{}, _field), do: query

  defp parse_sort_string(nil), do: [{@default_sort_field, @default_sort_dir}]
  defp parse_sort_string(""), do: [{@default_sort_field, @default_sort_dir}]

  defp parse_sort_string(sort_string) when is_binary(sort_string) do
    sort_string
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_sort_field/1)
    |> Enum.reject(&is_nil/1)
    |> then(&if &1 == [], do: [{@default_sort_field, @default_sort_dir}], else: &1)
  end

  defp parse_sort_field("-" <> field), do: build_sort_tuple(field, :desc)
  defp parse_sort_field(field), do: build_sort_tuple(field, :asc)

  defp build_sort_tuple(field_str, dir) do
    allowed_strings = Enum.map(@sortable_fields, &Atom.to_string/1)

    cond do
      field_str in allowed_strings ->
        {String.to_existing_atom(field_str), dir}

      true ->
        nil
    end
  rescue
    # handle unexpected input safely
    ArgumentError -> nil
  end

  defp apply_sort(query, field, dir) when field in @sortable_fields and dir in [:asc, :desc] do
    order_by(query, [r], [{^dir, field(r, ^field)}])
  end

  defp apply_sort(query, _field, _dir), do: query
end
