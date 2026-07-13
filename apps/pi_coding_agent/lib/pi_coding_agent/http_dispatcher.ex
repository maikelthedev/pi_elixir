defmodule PiCodingAgent.HTTPDispatcher do
  @moduledoc """
  HTTP proxy configuration and dispatcher setup.

  Reads proxy settings from environment (HTTP_PROXY, HTTPS_PROXY,
  NO_PROXY) and configures the Req client accordingly.
  """

  @doc "Applies proxy settings to a Req request builder."
  def apply_proxy(req) do
    proxy = System.get_env("HTTPS_PROXY") || System.get_env("HTTP_PROXY")

    case proxy do
      nil -> req
      url ->
        Req.merge(req, proxy: url)
    end
  end

  @doc "Returns the current proxy configuration."
  def config do
    %{
      http_proxy: System.get_env("HTTP_PROXY"),
      https_proxy: System.get_env("HTTPS_PROXY"),
      no_proxy: System.get_env("NO_PROXY"),
      proxy_enabled?: System.get_env("HTTP_PROXY") != nil
    }
  end

  @doc "Checks if a URL should bypass the proxy per NO_PROXY rules."
  def bypass_proxy?(url) do
    case System.get_env("NO_PROXY") do
      nil -> false
      no_proxy ->
        host = URI.parse(url).host || ""
        no_proxy
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.any?(fn pattern ->
          String.ends_with?(host, pattern)
        end)
    end
  end
end
