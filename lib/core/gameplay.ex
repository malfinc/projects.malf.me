defmodule Core.Gameplay do
  @moduledoc false
  import Core.Context

  resource(:plants, :plant, Core.Gameplay.Plant)
  resource(:seasons, :season, Core.Gameplay.Season)
  resource(:champions, :champion, Core.Gameplay.Champion)
  resource(:rarities, :rarity, Core.Gameplay.Rarity)
  resource(:coin_transactions, :coin_transaction, Core.Gameplay.CoinTransaction)
  resource(:challenges, :challenge, Core.Gameplay.Challenge)
  resource(:matches, :match, Core.Gameplay.Match)
end
