defmodule BattleNet.Regions do
  alias BattleNet.Locales.EN_US, as: EN_US
  alias BattleNet.Locales.ES_MX, as: ES_MX
  alias BattleNet.Locales.PT_BR, as: PT_BR
  alias BattleNet.Locales.DE_DE, as: DE_DE
  alias BattleNet.Locales.ES_ES, as: ES_ES
  alias BattleNet.Locales.FR_FR, as: FR_FR
  alias BattleNet.Locales.IT_IT, as: IT_IT
  alias BattleNet.Locales.PT_PT, as: PT_PT
  alias BattleNet.Locales.RU_RU, as: RU_RU
  alias BattleNet.Locales.KO_KR, as: KO_KR
  alias BattleNet.Locales.ZH_TW, as: ZH_TW
  alias BattleNet.Locales.ZH_CN, as: ZH_CN


  defmodule US do
    def name, do: "Europe"
    def api, do: "https://us.api.battle.net/"
    def oauth, do: "https://us.battle.net/"
    def locales, do: [EN_US, ES_MX, PT_BR]
  end

  defmodule EU do
    def name, do: "Usa"
    def api, do: "https://eu.api.battle.net/"
    def oauth, do: "https://eu.battle.net/"
    def locales, do: [EN_GB, ES_ES, FR_FR, RU_RU, DE_DE, PT_PT, IT_IT]
  end

  defmodule KR do
    def name, do: "Korea"
    def api, do: "https://kr.api.battle.net/"
    def oauth, do: "https://apac.battle.net/"
    def locales, do: [KO_KR]
  end

  defmodule TW do
    def name, do: "Taiwan"
    def api, do: "https://tw.api.battle.net/"
    def oauth, do: "https://apac.battle.net/"
    def locales, do: [ZH_TW]
  end

  defmodule CN do
    def name, do: "China"
    def api, do: "https://api.battlenet.com.cn/"
    def oauth, do: "https://www.battlenet.com.cn/"
    def locales, do: [ZH_CN]
  end

  defmodule EA do
    def name, do: "South east asia"
    def api, do: "https://sea.api.battle.net/"
    def oauth, do: "https://us.battle.net/"
    def locales, do: [EN_US]
  end

  def default_locale(region) do
    [head | _] = region.locales
    head
  end
end

