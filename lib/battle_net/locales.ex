defmodule BattleNet.Locales do
  defmodule EN_US do
    def code, do: "en_US"
  end

  defmodule EN_GB do
    def code, do: "en_GB"
  end

  defmodule ES_MX do
    def code, do: "es_MX"
  end

  defmodule PT_BR do
    def code, do: "pt_BR"
  end

  defmodule DE_DE do
    def code, do: "de_DE"
  end

  defmodule ES_ES do
    def code, do: "es_ES"
  end

  defmodule FR_FR do
    def code, do: "fr_FR"
  end

  defmodule IT_IT do
    def code, do: "it_IT"
  end

  defmodule PT_PT do
    def code, do: "pt_PT"
  end

  defmodule RU_RU do
    def code, do: "ru_RU"
  end

  defmodule KO_KR do
    def code, do: "ko_KR"
  end

  defmodule ZH_TW do
    def code, do: "zh_TW"
  end

  defmodule ZH_CN do
    def code, do: "zh_CN"
  end

  def code(locale), do: locale.code
end