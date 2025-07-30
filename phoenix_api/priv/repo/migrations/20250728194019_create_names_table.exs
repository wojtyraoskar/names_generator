defmodule PhoenixApi.Repo.Migrations.CreateNamesTable do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:names) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :birthdate, :date, null: false
      add :gender, :string, null: false

      timestamps()
    end

    # Add index on gender for faster filtering
    create_if_not_exists index(:names, [:gender])

    # Add index on first_name and last_name for faster searching
    create_if_not_exists index(:names, [:first_name])
    create_if_not_exists index(:names, [:last_name])

    # Add composite index for full name searches
    create_if_not_exists index(:names, [:first_name, :last_name])
  end
end
