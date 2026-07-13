defmodule PiCodingAgent.Harness.PromptTemplates do
  @moduledoc "Prompt template management for the harness."
  @templates %{
    system: "You are pi, a coding agent.",
    compact: "Summarize the following conversation concisely:\n\n{{conversation}}",
    review: "Review the following code and provide feedback:\n\n{{code}}",
    explain: "Explain the following:\n\n{{input}}"
  }

  def get(name), do: Map.get(@templates, name)
  def list, do: Map.keys(@templates)
  def all, do: @templates

  def render(name, bindings) do
    case get(name) do
      nil -> {:error, "Template not found: #{name}"}
      template ->
        result = Enum.reduce(bindings, template, fn {key, val}, acc ->
          String.replace(acc, "{{#{key}}}", val)
        end)
        {:ok, result}
    end
  end
end
