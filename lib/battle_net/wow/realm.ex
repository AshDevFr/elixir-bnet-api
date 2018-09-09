defmodule BattleNet.Wow.Realm do
  @moduledoc"""
  """

  @doc"""

  """
  def gen_url(region, endpoint) do
    region.api <> "wow/realm/" <> endpoint
  end

  def status(apikey, region, locale \\ nil) do
    region
    |> gen_url("status")
    |> BattleNet.Api.get(%{apikey: apikey, locale: BattleNet.Utils.ensure_locale(region, locale)}, [])
    |> (fn
          {200, answer} -> {:ok, answer}
          {_, %{error: error, reason: reason}} -> {:error, "#{error}; #{reason}"}
          {_, reason} -> {:error, reason}
        end).()
  end
end


