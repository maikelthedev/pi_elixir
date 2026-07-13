defmodule PiCodingAgent.Core.PromptTemplates do
  @moduledoc "Prompt template engine with variable substitution."
  defstruct [:templates]

  def new(templates \\ %{}) do
    defaults = %{
      "system" => "You are pi, a coding agent.",
      "compact" => "Summarize the following conversation concisely:\n\n{{conversation}}",
      "tool_error" => "Error executing tool: {{error}}",
      "trust_warning" => "This project is not trusted. Execute with caution.",
      "auth_prompt" => "Please set your {{provider}} API key.",
      "model_not_found" => "Model '{{model}}' not found. Available: {{available}}"
    }
    %__MODULE__{templates: Map.merge(defaults, templates)}
  end

  def render(%__MODULE__{templates: templates}, name, bindings \\ %{}) do
    case Map.get(templates, name) do
      nil -> {:error, :template_not_found}
      template ->
        rendered = Enum.reduce(bindings, template, fn {key, value}, acc ->
          String.replace(acc, "{{#{key}}}", to_string(value))
        end)
        {:ok, rendered}
    end
  end

  def render!(template_struct, name, bindings \\ %{}) do
    case render(template_struct, name, bindings) do
      {:ok, text} -> text
      {:error, reason} -> raise "Template error: #{inspect(reason)}"
    end
  end

  def add(%__MODULE__{} = pt, name, template) do
    %{pt | templates: Map.put(pt.templates, name, template)}
  end

  def remove(%__MODULE__{} = pt, name) do
    %{pt | templates: Map.delete(pt.templates, name)}
  end

  def list(%__MODULE__{templates: t}), do: Map.keys(t)
end
