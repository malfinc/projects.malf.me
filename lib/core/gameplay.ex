defmodule Core.Gameplay do
  import Core.Context

  resource(:plants, :plant, Core.Gameplay.Plant)
  resource(:seasons, :season, Core.Gameplay.Season)
  resource(:champions, :champion, Core.Gameplay.Champion)
end