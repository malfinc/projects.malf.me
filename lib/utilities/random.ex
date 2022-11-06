defmodule Utilities.Random do
  @moduledoc """
  Functionality dealing with randomness
  """
  require Utilities.Random.Dice

  Utilities.Random.Dice.dice_for(2)
  Utilities.Random.Dice.dice_for(4)
  Utilities.Random.Dice.dice_for(6)
  Utilities.Random.Dice.dice_for(8)
  Utilities.Random.Dice.dice_for(10)
  Utilities.Random.Dice.dice_for(12)
  Utilities.Random.Dice.dice_for(20)
  Utilities.Random.Dice.dice_for(100)
end
