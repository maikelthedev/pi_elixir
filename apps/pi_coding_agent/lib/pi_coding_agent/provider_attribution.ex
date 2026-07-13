defmodule PiCodingAgent.ProviderAttribution do
  @moduledoc "Provider attribution headers for OpenRouter and similar aggregators."
  def headers(provider) do
    app_name = "pi-coding-agent"
    app_url = "https://github.com/maikelthedev/pi-tools"
    case provider do
      "openrouter" -> [{"HTTP-Referer", app_url}, {"X-Title", app_name}]
      _ -> []
    end
  end
end
