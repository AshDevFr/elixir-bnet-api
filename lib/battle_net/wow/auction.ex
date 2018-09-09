defmodule BattleNet.Wow.Auction do
  @moduledoc"""
  """

  @doc"""

  """
  def gen_url(region, endpoint) do
    region.api <> "wow/auction/" <> endpoint
  end

  def data_status(apikey, region, realmSlug, locale \\ nil) do
    region
    |> gen_url("data/" <> realmSlug)
    |> BattleNet.Api.get(%{apikey: apikey, locale: BattleNet.Utils.ensure_locale(region, locale)}, [])
    |> (fn
          {200, answer} -> {:ok, answer}
          {_, %{error: error, reason: reason}} -> {:error, "#{error}; #{reason}"}
          {_, reason} -> {:error, reason}
        end).()
  end
end


