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

  def list(apikey, region, locale \\ nil) do
    status(apikey, region, locale)
    |> (fn
          {:ok, answer} -> answer |> parse_realms
          {_, _} -> []
        end).()
  end

  def parse_realms(answer) do
    case answer do
      %{realms: realms} ->
        realms
        |> Enum.map(
             fn realm -> %{name: realm.name, slug: realm.slug, status: realm.status, connected_realms: realm.connected_realms |> Enum.sort} end
           )
      _ -> []
    end
  end
end


