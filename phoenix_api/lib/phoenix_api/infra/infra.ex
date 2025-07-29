defmodule PhoenixApi.Infra do
  def empty?(nil), do: true
  def empty?([]), do: true
  def empty?(""), do: true
  def empty?(_any), do: false
end
