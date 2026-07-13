defmodule PiCodingAgent.OAuth.Provider do
  @moduledoc "Provider-specific OAuth configurations."
  def config("anthropic") do
    %{
      client_id: "anthropic-pi-agent",
      scope: "api_key:read write",
      device_url: "https://api.anthropic.com/v1/oauth/device/code",
      token_url: "https://api.anthropic.com/v1/oauth/token",
      user_agent: "pi-coding-agent/0.1.0"
    }
  end

  def config("openai") do
    %{
      client_id: "pi-coding-agent",
      scope: "openai.api.models.list openai.api.chat.completions.create",
      device_url: "https://auth.openai.com/oauth/device/code",
      token_url: "https://auth.openai.com/oauth/token",
      user_agent: "pi-coding-agent/0.1.0"
    }
  end

  def config("github-copilot") do
    %{
      client_id: "Iv1.b507d6b3a8a6b6b1",
      scope: "copilot",
      device_url: "https://github.com/login/device/code",
      token_url: "https://github.com/login/oauth/access_token",
      user_agent: "pi-coding-agent/0.1.0"
    }
  end

  def config("openai-codex") do
    %{
      client_id: "pi-codex-client",
      scope: "openai.codex.read openai.codex.write",
      device_url: "https://auth.openai.com/oauth/device/code",
      token_url: "https://auth.openai.com/oauth/token",
      user_agent: "pi-coding-agent/0.1.0"
    }
  end

  def config("google") do
    %{
      client_id: "pi-coding-agent",
      scope: "https://www.googleapis.com/auth/generative-language",
      device_url: "https://oauth2.googleapis.com/device/code",
      token_url: "https://oauth2.googleapis.com/token",
      user_agent: "pi-coding-agent/0.1.0"
    }
  end

  def config(provider) do
    %{
      client_id: "pi-coding-agent",
      scope: "default",
      device_url: nil,
      token_url: nil,
      user_agent: "pi-coding-agent/0.1.0"
    }
  end

  @spec login(String.t()) :: {:ok, map()} | {:error, String.t()}
  def login(provider) do
    cfg = config(provider)

    if cfg.device_url == nil do
      {:error, "OAuth not configured for #{provider}. Set #{String.upcase(provider)}_API_KEY instead."}
    else
      PiCodingAgent.OAuth.device_code(cfg.client_id, cfg.scope, cfg.token_url,
        device_url: cfg.device_url,
        headers: [{"user-agent", cfg.user_agent}]
      )
    end
  end
end
