defmodule PiCodingAgent.Core.ModelResolver do
  @moduledoc "Resolves model names from user-friendly names to provider/model format."

  def resolve(input) when is_binary(input) do
    input = String.trim(input)
    cond do
      String.contains?(input, "/") -> {:ok, input}
      true -> search_models(input)
    end
  end

  def resolve(nil), do: {:error, :nil_model}

  def search_models(query) do
    query = String.downcase(query)
    PiAi.ModelRegistry.list()
    |> Enum.filter(fn m -> String.contains?(String.downcase(m.id), query) or
                           String.contains?(String.downcase(m.name || ""), query) end)
    |> Enum.sort_by(& &1.id)
    |> Enum.map(& &1.id)
    |> case do
      [best | _] -> {:ok, best}
      [] -> {:error, :not_found}
    end
  end

  def list_providers do
    PiAi.ModelRegistry.list()
    |> Enum.group_by(& &1.provider)
    |> Enum.map(fn {provider, models} -> {provider, length(models)} end)
  end
end
