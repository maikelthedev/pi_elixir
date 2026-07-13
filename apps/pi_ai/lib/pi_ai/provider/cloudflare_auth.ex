defmodule PiAi.Provider.CloudflareAuth do
  @moduledoc "Cloudflare API token management for Workers AI and AI Gateway."
  def get_token do
    System.get_env("CLOUDFLARE_API_TOKEN") ||
    (try do
      {:ok, content} = File.read(Path.expand("~/.cloudflare/api_token"))
      String.trim(content)
    rescue _ -> nil end)
  end
  def get_account_id do
    System.get_env("CLOUDFLARE_ACCOUNT_ID") ||
    (try do
      {:ok, content} = File.read(Path.expand("~/.cloudflare/account_id"))
      String.trim(content)
    rescue _ -> nil end)
  end
end
