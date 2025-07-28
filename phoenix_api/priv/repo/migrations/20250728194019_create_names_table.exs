defmodule PhoenixApi.Repo.Migrations.CreateNamesTable do
  use Ecto.Migration

  def change do
    create table(:names) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :birthdate, :date, null: false
      add :gender, :string, null: false

      timestamps()
    end

    # Add index on gender for faster filtering
    create index(:names, [:gender])

    # Add index on first_name and last_name for faster searching
    create index(:names, [:first_name])
    create index(:names, [:last_name])

    # Add composite index for full name searches
    create index(:names, [:first_name, :last_name])
  end
end
