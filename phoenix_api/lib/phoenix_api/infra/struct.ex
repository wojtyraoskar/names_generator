defmodule PhoenixApi.Struct do
  defmacro fields do
    quote do
      unless Module.defines?(__MODULE__, {:fields, 0}) do
        def fields do
          __MODULE__.__schema__(:fields) -- [:inserted_at, :updated_at]
        end
      end
    end
  end

  defmacro __using__(args) do
    quote do
      import Ecto.Changeset
      use StructCop, unquote(args)
      defoverridable new: 1, new!: 1, changeset: 1

      def validate_require_all(changeset, opts \\ []) do
        required = __MODULE__.__schema__(:fields) -- Keyword.get(opts, :except, [])

        changeset
        |> validate_required(required)
      end

      def put_new(ch, field, value_callback) do
        ch
        |> put_change(field, get_field(ch, field) || value_callback.())
      end

      defdelegate to_map(struct), to: PhoenixApi.Struct

      PhoenixApi.Struct.fields()
    end
  end

  def to_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> Enum.into(%{}, fn
      {k, v} when is_list(v) ->
        {k, Enum.map(v, &to_map/1)}

      {k, v} ->
        {k, to_map(v)}
    end)
  end

  def to_map(any), do: any
end
