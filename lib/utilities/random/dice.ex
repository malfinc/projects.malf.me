defmodule Utilities.Random.Dice do
  @moduledoc """
  Dice Functions

  The basic dice functions are very simple, but effective. A function call for 'dX(Y)', where X is the sides on the die and Y is the number
  being rolled, will return a list of results. This works by feeding the sides and count argument to `roll()`, which in turn, calls on the
  `d(sides)` function.

  The `dX()` functions can be bypassed by using roll directly and providing it with the sides and count arguments.

  Additionally, a function call of `dX()` with no arguments, will cause a single result of the die-type to be generated and returned.

  Planned upgrades: I may need to code a version of this that returns just one die, then enum.sum's it, for reporting.
  """

  @doc """
  Defines a series of functions for rolling dice with `sides`.

      d2(10) == [1, 0, 1, 0, 1, 0, 1]
      oneD2() == 1
      sumD10(20) == 30
      highestD10(20) == 1
  """
  @spec dice_for(pos_integer()) :: any()
  defmacro dice_for(sides) when is_integer(sides) and sides > 1 do
    quote do
      @doc """
      Roll a `count`D#{unquote(sides)} dice.
      """
      @spec unquote(:"d#{sides}")(pos_integer()) :: list(pos_integer())
      def unquote(:"d#{sides}")(count)
          when is_integer(count) and count > 0,
          do: Utilities.Random.Dice.roll(unquote(sides), count)

      @doc """
      Roll a `count` #{unquote(sides)} sided dice, then return the total value.
      """
      @spec unquote(:"sumD#{sides}")(pos_integer()) :: pos_integer()
      def unquote(:"sumD#{sides}")(count)
          when is_integer(count) and count > 0,
          do: unquote(sides) |> Utilities.Random.Dice.roll(count) |> Enum.sum()

      @doc """
      Roll a 1d#{unquote(sides)}, then return the total value.
      """
      @spec unquote(:"oneD#{sides}")() :: pos_integer()
      def unquote(:"oneD#{sides}")(),
        do: unquote(sides) |> Utilities.Random.Dice.roll(1) |> List.first()
    end
  end

  @doc """
  Generate a value between 1 and `sides` `count` times.
  """
  @spec roll(pos_integer, pos_integer) :: list(pos_integer())
  def roll(sides, count)
      when is_integer(count) and count > 0 and is_integer(sides) and sides > 1 do
    1..count |> Enum.map(fn _ -> Enum.random(1..sides) end)
  end
end
