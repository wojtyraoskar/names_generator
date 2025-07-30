defmodule PhoenixApi.Release do
  @app :phoenix_api

  def migrate do
    load_app()

    for repo <- repos() do
      try do
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
      rescue
        e in DBConnection.EncodeError ->
          IO.puts("Migration already completed or encoding error: #{inspect(e)}")
          :ok

        e in Postgrex.Error ->
          IO.puts("Migration already completed or database error: #{inspect(e)}")
          :ok
      end
    end
  end

  def create_and_migrate do
    load_app()

    for repo <- repos() do
      :ok = ensure_repo_created(repo)
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def create do
    load_app()

    for repo <- repos() do
      :ok = ensure_repo_created(repo)
    end
  end

  def reset do
    load_app()

    for repo <- repos() do
      :ok = ensure_repo_dropped(repo)
      :ok = ensure_repo_created(repo)
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def drop do
    load_app()

    for repo <- repos() do
      :ok = ensure_repo_dropped(repo)
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    [PhoenixApi.Repo]
  end

  defp load_app do
    Application.load(@app)
  end

  defp ensure_repo_created(repo) do
    IO.puts("Creating #{inspect(repo)} database if it doesn't exist...")

    case repo.__adapter__().storage_up(repo.config) do
      :ok -> :ok
      {:error, :already_up} -> :ok
      {:error, term} -> {:error, term}
    end
  end

  defp ensure_repo_dropped(repo) do
    IO.puts("Dropping #{inspect(repo)} database...")

    case repo.__adapter__().storage_down(repo.config) do
      :ok -> :ok
      {:error, :already_down} -> :ok
      {:error, term} -> {:error, term}
    end
  end
end
