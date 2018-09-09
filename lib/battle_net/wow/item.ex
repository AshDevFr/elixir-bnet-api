defmodule BattleNet.Wow.Item do
  @moduledoc"""
  """

  @doc"""

  """
  def gen_url(region, endpoint) do
    region.api <> "wow/item/" <> endpoint
  end

  def get(apikey, region, itemId, locale \\ nil) do
    region
    |> gen_url(itemId)
    |> BattleNet.Api.get(%{apikey: apikey, locale: BattleNet.Utils.ensure_locale(region, locale)}, [])
    |> (fn
          {200, answer} -> {:ok, answer}
          {_, %{error: error, reason: reason}} -> {:error, "#{error}; #{reason}"}
          {_, reason} -> {:error, reason}
        end).()
  end

  def get_set(apikey, region, setId, locale \\ nil) do
    region
    |> gen_url("set/" <> setId)
    |> BattleNet.Api.get(%{apikey: apikey, locale: BattleNet.Utils.ensure_locale(region, locale)}, [])
    |> (fn
          {200, answer} -> {:ok, answer}
          {_, %{error: error, reason: reason}} -> {:error, "#{error}; #{reason}"}
          {_, reason} -> {:error, reason}
        end).()
  end
end


