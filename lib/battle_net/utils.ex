defmodule BattleNet.Utils do
  @moduledoc"""
  """

  @doc"""

  """

  def ensure_locale(region, locale \\ nil) do
    case locale do
      nil -> BattleNet.Locales.code(BattleNet.Regions.default_locale(region))
      l -> l.code
    end
  end
end
