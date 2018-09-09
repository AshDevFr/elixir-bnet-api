defmodule BattleNet.Api do
  @moduledoc"""
  Make generic HTTP calls a web service.
  """

  @default_service_url BattleNet.Regions.US.api


  @doc"""
  Retrieve data from the API using any method (:get, :post, :put, :delete, etc) available

  ## Examples

      iex> BattleNet.Api.call("https://us.api.battle.net", :post, %{version: "2.0.0"}, %{user: "james"})
      {201, %{version: "2.0.0", user: "james"}}

  """
  def call(url, method, body \\ "", query_params \\ %{}, headers \\ []) do
    HTTPoison.request(
      method,
      url |> clean_url,
      body |> encode(content_type(headers)),
      headers |> clean_headers,
      query_params |> clean_params
    )
    |> case do
        {:ok, %{body: raw_body, status_code: code, headers: headers}} ->
          {code, raw_body, headers}
        {:error, %{reason: reason}} -> {:error, reason, []}
       end
    |> content_type
    |> decode
  end

  @doc"""
  Send a GET request to the API

  ## Examples

      iex> BattleNet.Api.get("https://us.api.unknown.com")
      {:error, :econnrefused}

      iex> BattleNet.Api.get("https://us.api.battle.net")
      {200, %{version: "0.1.0"}}

      iex> BattleNet.Api.get("https://us.api.battle.net", %{user: "andrew"})
      {200, %{version: "0.1.0", user: "andrew"}}

      iex> BattleNet.Api.get("https://us.api.battle.net/droids/bb10")
      {404, %{error: "unknown_resource", reason: "/droids/bb10 is not the path you are looking for"}}
  """
  def get(url, query_params \\ %{}, headers \\ []) do
    call(url, :get, "", query_params, headers)
  end

  @doc"""
  Send a POST request to the API

  ## Examples

      iex> BattleNet.Api.post("https://us.api.battle.net", %{version: "2.0.0"})
      {201, %{version: "2.0.0"}}

  """
  def post(url, body \\ nil, headers \\ []) do
    call(url, :post, body, %{}, headers)
  end

  @doc"""
  Send a PUT request to the API
  """
  def put(url, body \\ nil, headers \\ []) do
    call(url, :put, body, %{}, headers)
  end

  @doc"""
  Send a DELETE request to the API
  """
  def delete(url, query_params \\ %{}, headers \\ []) do
    call(url, :delete, "", query_params, headers)
  end

  @doc"""
  The service's default URL, it will lookup the config,
  possibly check the env variables and default if still not found

  ## Examples

      iex> BattleNet.Api.service_url()
      "https://us.api.battle.net"

  """
  def service_url() do
    Application.get_env(:battle_net, :service_url)
    |> case do
         {:system, lookup} -> System.get_env(lookup)
         nil -> @default_service_url
         url -> url
       end
  end

  @doc"""
  Extract the content type of the headers

  ## Examples

      iex> BattleNet.Api.content_type({:ok, "<xml />", [{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}]})
      {:ok, "<xml />", "application/xml"}

      iex> BattleNet.Api.content_type([])
      "application/json"

      iex> BattleNet.Api.content_type([{"Content-Type", "plain/text"}])
      "plain/text"

      iex> BattleNet.Api.content_type([{"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"

      iex> BattleNet.Api.content_type([{"Server", "GitHub.com"}, {"Content-Type", "application/xml; charset=utf-8"}])
      "application/xml"
  """
  def content_type({ok, body, headers}), do: {ok, body, content_type(headers)}
  def content_type([]), do: "application/json"
  def content_type([{ "Content-Type", val } | _]), do: val |> String.split(";") |> List.first
  def content_type([_ | t]), do: t |> content_type

  @doc"""
  Encode the body to pass along to the server

  ## Examples

      iex> BattleNet.Api.encode(%{a: 1}, "application/json")
      "{\\"a\\":1}"

      iex> BattleNet.Api.encode("<xml/>", "application/xml")
      "<xml/>"

      iex> BattleNet.Api.encode(%{a: "o ne"}, "application/x-www-form-urlencoded")
      "a=o+ne"

      iex> BattleNet.Api.encode("goop", "application/mytsuff")
      "goop"

  """
  def encode(data, "application/json"), do: Poison.encode!(data)
  def encode(data, "application/xml"), do: data
  def encode(data, "application/x-www-form-urlencoded"), do: URI.encode_query(data)
  def encode(data, _), do: data

  @doc"""
  Decode the response body

  ## Examples

      iex> BattleNet.Api.decode({:ok, "{\\\"a\\\": 1}", "application/json"})
      {:ok, %{a: 1}}

      iex> BattleNet.Api.decode({500, "", "application/json"})
      {500, ""}

      iex> BattleNet.Api.decode({:error, "{\\\"a\\\": 1}", "application/json"})
      {:error, %{a: 1}}

      iex> BattleNet.Api.decode({:ok, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> BattleNet.Api.decode({:error, "{goop}", "application/json"})
      {:error, "{goop}"}

      iex> BattleNet.Api.decode({:error, :nxdomain, "application/dontcare"})
      {:error, :nxdomain}

  """
  def decode({ok, body, _}) when is_atom(body), do: {ok, body}
  def decode({ok, "", _}), do: {ok, ""}
  def decode({ok, body, "application/json"}) when is_binary(body) do
    body
    |> Poison.decode(keys: :atoms)
    |> case do
         {:ok, parsed} -> {ok, parsed}
         _ -> {:error, body}
       end
  end
  def decode({ok, body, "application/xml"}) do
    try do
      {ok, body |> :binary.bin_to_list |> :xmerl_scan.string}
    catch
      :exit, _e -> {:error, body}
    end
  end
  def decode({ok, body, _}), do: {ok, body}


  @doc"""
  Clean the URL, if there is a port, but nothing after, then ensure there's a
  ending '/' otherwise you will encounter something like
  hackney_url.erl:204: :hackney_url.parse_netloc/2

  ## Examples

      iex> BattleNet.Api.clean_url("https://us.api.battle.net")
      "https://us.api.battle.net"

      iex> BattleNet.Api.clean_url("https://us.api.battle.net/b")
      "https://us.api.battle.net/b"

      iex> BattleNet.Api.clean_url("https://us.api.battle.net:80")
      "https://us.api.battle.net:80/"

  """
  def clean_url(url \\ nil) do
    url
    |> endpoint_url
    |> slash_cleanup
  end

  defp endpoint_url(endpoint) do
    case endpoint do
       nil -> service_url()
       "" -> service_url()
       "/" <> _ -> service_url() <> endpoint
       _ -> endpoint
     end
  end

  defp slash_cleanup(url) do
    url
    |> String.split(":")
    |> List.last
    |> Integer.parse
    |> case do
         {_, ""} -> url <> "/"
         _ -> url
       end
  end

  @doc"""
  Clean the headers
  Also allow headers to be provided as a %{}, makes it easier to ensure defaults are
  set

  ## Examples

      iex> BattleNet.Api.clean_headers(%{})
      [{"Content-Type", "application/json; charset=utf-8"}]

      iex> BattleNet.Api.clean_headers(%{"Content-Type" => "application/xml"})
      [{"Content-Type", "application/xml"}]

      iex> BattleNet.Api.clean_headers(%{"Authorization" => "Bearer abc123"})
      [{"Authorization","Bearer abc123"}, {"Content-Type", "application/json; charset=utf-8"}]

      iex> BattleNet.Api.clean_headers(%{"Authorization" => "Bearer abc123", "Content-Type" => "application/xml"})
      [{"Authorization","Bearer abc123"}, {"Content-Type", "application/xml"}]

      iex> BattleNet.Api.clean_headers([])
      [{"Content-Type", "application/json; charset=utf-8"}]

      iex> BattleNet.Api.clean_headers([{"apples", "delicious"}])
      [{"Content-Type", "application/json; charset=utf-8"}, {"apples", "delicious"}]

      iex> BattleNet.Api.clean_headers([{"apples", "delicious"}, {"Content-Type", "application/xml"}])
      [{"apples", "delicious"}, {"Content-Type", "application/xml"}]

  """
  def clean_headers(h) when is_map(h) do
    %{"Content-Type" => "application/json; charset=utf-8"}
    |> Map.merge(h)
    |> Enum.map(&(&1))
  end
  def clean_headers(h) when is_list(h) do
    h
    |> Enum.filter(fn {k,_v} -> k == "Content-Type" end)
    |> case do
         [] -> [{"Content-Type", "application/json; charset=utf-8"} | h ]
         _ -> h
       end
  end

  def clean_params(query_params) when query_params == %{}, do: []
  def clean_params(query_params), do: [{:params, query_params}]

end