defmodule Utilities.List do
  @moduledoc """
  Extra functionality relating to lists
  """

  @spec find_header(list({key, value}), key, default) :: value | default
        when key: String.t(), value: String.t(), default: any
  def find_header(headers, key, default \\ nil) when is_list(headers) and is_binary(key) do
    headers
    |> Enum.find(default, fn {header, _value} -> header == key end)
    |> Utilities.Tuple.right()
  end

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

  @spec pluck(list(map()), any() | list(any())) :: list(any())
  def pluck(maps, key)
      when (is_list(maps) and is_atom(key)) or is_binary(key) or is_integer(key) do
    Enum.map(maps, &Map.get(&1, key))
  end

  def pluck(maps, path) when is_list(maps) and is_list(path) do
    Enum.map(maps, &Utilities.Map.dig(&1, path))
  end

  @spec delete_all(list(), list()) :: list()
  def delete_all(all, picked) do
    all
    |> Enum.reduce([], fn item, remaining_items ->
      if Enum.member?(picked, item) do
        remaining_items
      else
        [item | remaining_items]
      end
    end)
  end

  @spec to_sentence(list(String.t()), String.t() | nil) :: String.t()
  def to_sentence(list, combinator \\ "and")
  def to_sentence([], _), do: ""

  def to_sentence(list, combinator) when is_list(list) and is_binary(combinator) do
    [butt | body] = list |> Enum.reverse()

    cond do
      length(body) < 1 -> butt
      length(body) == 1 -> "#{body} #{combinator} #{butt}"
      length(body) > 1 -> "#{body |> Enum.reverse() |> Enum.join(", ")}, #{combinator} #{butt}"
    end
  end
end
