defmodule Utilities.Enum do
  @moduledoc """
  Houses a bunch of enumerable based functionality
  """

  @spec split(list(tuple())) :: {list(), list()}
  def split(list) when is_list(list) do
    list
    |> Enum.reduce({[], []}, fn {left, right}, {lefts, rights} ->
      {
        List.insert_at(lefts, -1, left),
        List.insert_at(rights, -1, right)
      }
    end)
  end

  @spec times(pos_integer(), function()) :: any()
  def times(0, _), do: []
  def times(1, function) when is_function(function, 0), do: [function.()]

  def times(amount, function)
      when is_integer(amount) and amount >= 1 and is_function(function, 0) do
    1..amount
    |> Enum.map(fn _ -> function.() end)
  end
end
