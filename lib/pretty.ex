defmodule Pretty do
  @moduledoc """
  Decorating getters for display.
  """

  @spec get(struct() | map(), atom() | list(atom())) :: any()

  def get(record, keys) when is_list(keys),
    do: keys |> Enum.reduce(record, fn value, accumulated -> get(accumulated, value) end)

  def get(%Core.Content.Hall{deadline_at: deadline_at, category: category}, :name),
    do:
      Utilities.String.titlecase("#{Timex.format!(deadline_at, "{Mfull}")}'s Hall of #{category}")

  def get(
        %Core.Gameplay.Match{left_champion: left_champion, right_champion: right_champion},
        :name
      ),
      do: "#{left_champion.name} Vs #{right_champion.name}"

  def get(%{name: name}, :name) when is_binary(name), do: Utilities.String.titlecase(name)

  def get(record, key) when is_map_key(record, key), do: Map.get(record, key)
end
