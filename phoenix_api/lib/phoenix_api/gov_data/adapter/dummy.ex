defmodule PhoenixApi.GovData.NamesBaseOnPesel.Adapter.Dummy do
  @behaviour PhoenixApi.GovData.NamesBaseOnPesel

  def fetch_female_names() do
    {:ok, ["Anna", "Maria", "Katarzyna", "Agnieszka", "Barbara"]}
  end

  def fetch_male_names() do
    {:ok, ["Jan", "Piotr", "Andrzej", "Tomasz", "Marek"]}
  end

  def fetch_female_lastnames() do
    {:ok, ["Kowalska", "Nowak", "Wiśniewska", "Wójcik", "Kowalczyk"]}
  end

  def fetch_male_lastnames() do
    {:ok, ["Kowalski", "Nowak", "Wiśniewski", "Wójcik", "Kowalczyk"]}
  end
end
