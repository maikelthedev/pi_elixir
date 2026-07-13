defmodule PiCodingAgent.Core.ProviderDisplayNames do
  @moduledoc "Human-readable display names for providers and models."

  def display_name(model_id) do
    case String.split(model_id, "/", parts: 2) do
      [_provider, model] -> format_model_name(model)
      [model] -> format_model_name(model)
    end
  end

  def provider_display_name(provider) do
    provider
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp format_model_name(name) do
    name
    |> String.replace("-", " ")
    |> String.replace("_", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def short_name(model_id) do
    case String.split(model_id, "/") do
      parts when length(parts) > 1 -> List.last(parts)
      _ -> model_id
    end
    |> String.split("-")
    |> Enum.take(2)
    |> Enum.join("-")
  end

  def model_with_provider(model_id) do
    case String.split(model_id, "/", parts: 2) do
      [provider, model] -> "#{provider_display_name(provider)} / #{display_name(model)}"
      [model] -> display_name(model)
    end
  end
end
