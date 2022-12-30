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

  @spec pluck(list(map()), any() | list(any)) :: list(any())
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

  @doc """
  This function takes a list of weighted values, buckets them
  based on the Alias Method algorithms, and efficiently picks
  a random value from the list.

  This implements Walker's Alias Method, an algorithms
  for taking a list of weighted options: apples (40%),
  oranges (10%), banans (50%) and randomly picking
  a result.
  """
  @spec random(list({any(), float() | integer()})) :: any()
  def random(weighted_options) when is_list(weighted_options) do
    {options, weights} = weighted_options |> Utilities.List.split()
    total = Enum.sum(weights) / 1.0
    length = length(weights)

    initial_probabilities =
      Enum.map(weights, fn weight ->
        weight * length / total
      end)

    {inner, probabilities} =
      initial_probabilities
      |> Enum.with_index()
      |> Enum.reduce({[], []}, fn {probability, index}, {shorts, longs} ->
        if probability < 1 do
          {List.insert_at(shorts, index, -1), longs}
        else
          {shorts, List.insert_at(longs, index, -1)}
        end
      end)
      |> rebucket(List.duplicate(-1, length), initial_probabilities)

    random_number = :rand.uniform() |> Float.round(4)

    j = floor(random_number * length)

    if random_number <= Enum.at(probabilities, j) do
      Enum.at(options, j)
    else
      options |> Enum.at(Enum.at(inner, j))
    end
  end

  # @spec rebucket({list(integer()), list(integer())}, list(integer()), list(float())) :: {list(integer()), list(integer())}
  defp rebucket({_, []}, inner, probabilities) when is_list(inner) and is_list(probabilities),
    do: {inner, probabilities}

  defp rebucket({[], _}, inner, probabilities) when is_list(inner) and is_list(probabilities),
    do: {inner, probabilities}

  defp rebucket({shorts, longs}, inner, probabilities)
       when is_list(shorts) and is_list(longs) and is_list(inner) and is_list(probabilities) do
    {j, remaining_shorts} = List.pop_at(shorts, -1)

    k = Enum.at(longs, -1)

    new_inner = List.replace_at(inner, j, k)

    left =
      probabilities
      |> Enum.at(k, 0)
      |> Float.round(4)

    right =
      probabilities
      |> Enum.at(j)
      |> Float.round(4)

    new_probabilities = List.replace_at(probabilities, k, left - 1 - right)

    if Enum.at(probabilities, k) < 1 do
      {_, remaining_longs} = List.pop_at(longs, -1)

      rebucket({remaining_shorts ++ [k], remaining_longs}, new_inner, new_probabilities)
    else
      rebucket({remaining_shorts, longs}, new_inner, new_probabilities)
    end
  end
end
