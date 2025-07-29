defmodule PhoenixApi.RandomNames.Service do
  alias PhoenixApi.Repo
  alias PhoenixApi.RandomNames.Query, as: Q
  alias PhoenixApi.RandomNames.RandomName
  import Ecto.Query

  def list_users(params) do
    with {:ok, struct} <- Q.new(params),
         {:ok, query} <- Q.call(struct) do
      # Get total count for pagination metadata by applying the same filters
      count_query = build_count_query(struct)
      total_count = Repo.one(count_query) || 0

      # Get paginated results
      results = Repo.all(query)

      # Calculate pagination metadata
      page = struct.page
      per_page = struct.per_page
      total_pages = if per_page > 0, do: ceil(total_count / per_page), else: 0

      {:ok,
       %{
         data: results,
         pagination: %{
           page: page,
           per_page: per_page,
           total_count: total_count,
           total_pages: total_pages,
           has_next: page < total_pages,
           has_prev: page > 1
         }
       }}
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

  defp build_count_query(%Q{} = struct) do
    RandomName
    |> filter_by_first_name(struct.first_name)
    |> filter_by_last_name(struct.last_name)
    |> filter_by_birthdate(struct.birthdate)
    |> filter_by_birthdate_from(struct.birthdate_from)
    |> filter_by_birthdate_to(struct.birthdate_to)
    |> filter_by_gender(struct.gender)
    |> select([r], count(r.id))
  end

  defp filter_by_first_name(query, nil), do: query

  defp filter_by_first_name(query, first_name) do
    query |> where([r], ilike(r.first_name, ^"%#{first_name}%"))
  end

  defp filter_by_last_name(query, nil), do: query

  defp filter_by_last_name(query, last_name) do
    query |> where([r], ilike(r.last_name, ^"%#{last_name}%"))
  end

  defp filter_by_birthdate(query, nil), do: query

  defp filter_by_birthdate(query, birthdate) do
    query |> where([r], r.birthdate == ^birthdate)
  end

  defp filter_by_birthdate_from(query, nil), do: query

  defp filter_by_birthdate_from(query, birthdate_from) do
    query |> where([r], r.birthdate >= ^birthdate_from)
  end

  defp filter_by_birthdate_to(query, nil), do: query

  defp filter_by_birthdate_to(query, birthdate_to) do
    query |> where([r], r.birthdate <= ^birthdate_to)
  end

  defp filter_by_gender(query, nil), do: query

  defp filter_by_gender(query, gender) do
    query |> where([r], r.gender == ^gender)
  end
end
