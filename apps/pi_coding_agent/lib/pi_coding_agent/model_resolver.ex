defmodule PiCodingAgent.ModelResolver do
  @moduledoc "Resolves model names from user-friendly names to provider/model format."
  require Logger

  @aliases %{
    "sonnet" => "anthropic/claude-sonnet-4-20250514",
    "claude" => "anthropic/claude-sonnet-4-20250514",
    "opus" => "anthropic/claude-opus-4-20250514",
    "haiku" => "anthropic/claude-haiku-4-20250514",
    "gpt4" => "openai/gpt-4.1",
    "gpt-4" => "openai/gpt-4.1",
    "o3" => "openai/o3",
    "o4" => "openai/o4-mini",
    "gemini" => "gemini/gemini-2.5-pro",
    "flash" => "gemini/gemini-2.5-flash",
    "deepseek" => "deepseek/deepseek-chat",
    "grok" => "xai/grok-3",
    "qwen" => "openrouter/qwen3-235b-a22b"
  }

  def resolve(input) when is_binary(input) do
    input = String.trim(input)
    cond do
      String.contains?(input, "/") -> {:ok, input}
      Map.has_key?(@aliases, String.downcase(input)) -> {:ok, Map.fetch!(@aliases, String.downcase(input))}
      true ->
        case search_models(input) do
          [best | _] -> {:ok, best}
          [] -> {:error, :not_found}
        end
    end
  end

  def resolve(nil), do: {:error, :nil_model}

  def search_models(query) do
    query = String.downcase(query)
    PiAi.ModelRegistry.list()
    |> Enum.filter(fn m -> String.contains?(String.downcase(m.id), query) or String.contains?(String.downcase(m.name), query) end)
    |> Enum.sort_by(& &1.id)
    |> Enum.map(& &1.id)
  end

  def list_providers do
    PiAi.ModelRegistry.list()
    |> Enum.group_by(& &1.provider)
    |> Enum.map(fn {provider, models} -> {provider, length(models)} end)
  end
end
