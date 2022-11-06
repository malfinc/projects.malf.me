defmodule Utilities do
  @moduledoc """
  Generic behavior that we use elsewhere.
  """

  @doc """
  Determines if the value is considered present, which is non-empty for values that
  contain data like `[]`.
  """
  @spec present?(any()) :: boolean()
  def present?(nil), do: false
  def present?(false), do: false
  def present?(%{}), do: false
  def present?([]), do: false
  def present?(""), do: false
  def present?(0), do: false
  def present?({}), do: false
  def present?(_), do: true

  @doc """
  Takes a function that contains some amount of work then measures
  the time between work start and work finish. The return value is
  the number of seconds.
  """
  @spec measure((() -> any())) :: {float(), any()}
  def measure(function) when is_function(function, 0) do
    {nsec, value} = :timer.tc(function)

    {nsec / 1_000_000.0, value}
  end

  @doc """
  Wraps a papertrail result so that our existing infrastructure isn't changed
  """
  # @spec with_version({:ok, %{model: struct(), version: struct()}} | {:error, Ecto.Changeset.t()}) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def with_version({:ok, %{model: model, version: _version}}), do: {:ok, model}
  def with_version({:error, _changeset} = result), do: result
end
