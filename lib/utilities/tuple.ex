defmodule Utilities.Tuple do
  @moduledoc """
  Behavior relating to tuples
  """

  @spec right({any, value}) :: value when value: any
  def right({_, value}) do
    value
  end

  @spec left({value, any}) :: value when value: any
  def left({value, _}) do
    value
  end

  @spec result(any(), atom()) :: {atom(), any()}
  def result(value, key) when is_atom(key) do
    {key, value}
  end

  @spec result(any(), atom(), any()) :: {atom(), any(), any()}
  def result(value, key, extra) when is_atom(key) do
    {key, value, extra}
  end
end
