defmodule Core.Decorate do
  @moduledoc """
  Behavior for wrapping around records to create presentational structures.
  """

  @ignored_keys [
    :__meta__,
    :__source__
  ]
  @spec deep(list(struct()) | struct()) :: list(map) | map()
  @doc """
  Wraps each item in `list` with `Core.Decorate.deep/1`.

  Wraps the `record` in a map based on `Core.Decorate.wrap/1`, pattern matching to the struct.

  The original `record` gets stored as `:__source__` on the returned map.

  The returned map will have a `:decorated` key with the value `true`. Any `record` with the
  `decorated` property set to true is skipped, it's already decorated.

  Only functions on structs with a `:__meta__` key, like from `Ecto`.
  """
  def deep([]), do: []
  def deep(list) when is_list(list), do: Enum.map(list, &deep/1)
  def deep(%{decorated: true} = record), do: record

  def deep(record)
      when is_struct(record) and is_map_key(record, :__meta__) do
    record
    |> Map.merge(wrap(record))
    |> Map.from_struct()
    |> Map.merge(%{decorated: true, __source__: record})
    |> Enum.map(fn
      {key, value} when key in @ignored_keys -> {key, value}
      {key, value} -> {key, deep(value)}
    end)
    |> Map.new()
  end

  def deep(value), do: value

  defp wrap(value), do: value
end
