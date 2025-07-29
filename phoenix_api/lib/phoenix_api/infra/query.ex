defmodule PhoenixApi.Query do
  @moduledoc """
  Definition of generic query object
  """

  @callback call(base_query :: any(), struct) :: {:ok, %Ecto.Query{}}
  @callback defaults() :: keyword()
  @callback to_query_params(struct) :: String.t()

  defmacro __using__(_args) do
    quote do
      @behaviour PhoenixApi.Query

      use PhoenixApi.Struct
      import Ecto.Query
      alias __MODULE__, as: Q

      def call(base_query \\ base_query(), attrs)

      def call(base_query, %{__struct__: __MODULE__} = q) do
        __MODULE__.fields()
        |> Enum.reduce(base_query, fn filter, query ->
          if q |> get_in([Access.key(filter)]) |> PhoenixApi.Infra.empty?() do
            query
          else
            query
            |> apply_filter(q, filter)
          end
        end)
        |> then(&{:ok, &1})
      end

      def call(base_query, attrs) do
        with {:ok, query} <- new(attrs) do
          call(base_query, query)
        end
      end

      def defaults,
        do: new!() |> Map.from_struct() |> Enum.reject(fn {_k, v} -> PhoenixApi.Infra.empty?(v) end)

      defdelegate to_query_params(struct), to: PhoenixApi.Query

      defoverridable call: 1
    end
  end

  def to_query_params(%struct_mod{} = struct) do
    defaults = struct_mod.defaults()

    struct
    |> Map.from_struct()
    |> Enum.reject(fn {k, v} -> defaults[k] == v || PhoenixApi.Infra.empty?(v) end)
    |> Enum.map(fn
      {k, v} when is_list(v) ->
        {k, Enum.join(v, ",")}

      {k, v} ->
        {k, v}
    end)
    |> case do
      [] ->
        ""

      params ->
        "?" <> URI.encode_query(params)
    end
  end
end
