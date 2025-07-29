defmodule PhoenixApi.RandomNames.Service do
  alias PhoenixApi.Repo
  alias PhoenixApi.RandomNames.Query, as: Q
  alias PhoenixApi.RandomNames.RandomName

  def list_users(params) do
    with {:ok, struct} <- Q.new(params),
         {:ok, query} <- Q.call(struct) do
      Repo.all(query)
    else
      _ -> {:error, "Failed to fetch names data"}
    end
  end

  def get_user(id) do
    with %RandomName{} = user <- Repo.get(RandomName, id) do
      {:ok, user}
    else
      nil -> {:error, "User not found"}
    end
  end

  def create_user(attrs) do
    with {:ok, changeset} <- validate_changeset(%RandomName{}, attrs),
         {:ok, user} <- Repo.insert(changeset) do
      {:ok, user}
    else
      {:error, changeset} -> {:error, "Failed to create user: #{inspect(changeset.errors)}"}
    end
  end

  def update_user(id, attrs) do
    with %RandomName{} = user <- Repo.get(RandomName, id),
         {:ok, changeset} <- validate_changeset(user, attrs),
         {:ok, updated_user} <- Repo.update(changeset) do
      {:ok, updated_user}
    else
      nil -> {:error, "User not found"}
      {:error, changeset} -> {:error, "Failed to update user: #{inspect(changeset.errors)}"}
    end
  end

  def delete_user(id) do
    with %RandomName{} = user <- Repo.get(RandomName, id),
         {:ok, deleted_user} <- Repo.delete(user) do
      {:ok, deleted_user}
    else
      nil -> {:error, "User not found"}
      {:error, _changeset} -> {:error, "Failed to delete user"}
    end
  end

  defp validate_changeset(user, attrs) do
    case RandomName.changeset(user, attrs) do
      %Ecto.Changeset{valid?: true} = changeset -> {:ok, changeset}
      changeset -> {:error, changeset}
    end
  end
end
