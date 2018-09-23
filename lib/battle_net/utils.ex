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

  @doc"""
  """
  def err_to_string(%{code: code, detail: detail, type: type}) do
    "#{code}(#{type}) - #{detail}"
  end
  def err_to_string(_) do
    ""
  end
end
