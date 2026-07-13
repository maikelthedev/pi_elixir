defmodule PiCodingAgent.ResolveConfigValue do
  @moduledoc "Resolves configuration values with environment variable fallbacks."
  @doc "Resolves a value that may be a static string, env var ref, or default."
  def resolve(value, default \\ nil) do
    case value do
      nil -> default
      "$" <> rest -> resolve_env_ref(rest, default)
      other -> other
    end
  end
  defp resolve_env_ref(name, default), do: System.get_env(name) || default
end
