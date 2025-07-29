defmodule PhoenixApi.RandomNames.RandomName do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :first_name, :last_name, :birthdate, :gender, :inserted_at, :updated_at]}
  schema "names" do
    field :first_name, :string
    field :last_name, :string
    field :birthdate, :date
    field :gender, Ecto.Enum, values: [:male, :female]

    timestamps()
  end

  @doc false
  def changeset(name, attrs) do
    name
    |> cast(attrs, [:first_name, :last_name, :birthdate, :gender])
    |> validate_required([:first_name, :last_name, :birthdate, :gender])
    |> validate_length(:first_name, min: 1, max: 100)
    |> validate_length(:last_name, min: 1, max: 100)
  end
end
