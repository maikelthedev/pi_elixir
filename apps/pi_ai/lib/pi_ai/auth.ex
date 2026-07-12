defmodule PiAi.Auth do
  @moduledoc """
  Manages API key storage for LLM providers.

  Keys are stored in a JSON file at the configured auth path, keyed by provider name.
  Uses Elixir's built-in `JSON` module (no Jason dependency).
  """

  @default_filename "auth.json"

  @doc """
  Loads auth config for a given `provider` from a JSON file in `dir`.

  Returns `{:ok, config_map | nil}` on success, or `{:error, reason}` on parse failure.
  """
  @spec load(String.t(), String.t()) :: {:ok, map() | nil} | {:error, term()}
  def load(provider, dir \\ default_dir()) do
    path = Path.join(dir, @default_filename)

    case File.read(path) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, all} -> {:ok, Map.get(all, provider)}
          {:error, _} = err -> err
        end

      {:error, :enoent} ->
        {:ok, nil}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Saves auth config for `provider` into a JSON file in `dir`.

  Merges with existing providers so other provider keys are preserved.
  """
  @spec save(String.t(), map(), String.t()) :: :ok
  def save(provider, config, dir \\ default_dir()) do
    path = Path.join(dir, @default_filename)
    existing = load_all(path)

    merged = Map.put(existing, provider, config)
    File.mkdir_p!(dir)
    File.write!(path, JSON.encode!(merged))
  end

  defp load_all(path) do
    case File.read(path) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, map} -> map
          {:error, _} -> %{}
        end

      {:error, _} ->
        %{}
    end
  end

  defp default_dir do
    # Default to ~/.pi/agent — matching the TypeScript project's convention
    Path.expand("~/.pi/agent")
  end
end
