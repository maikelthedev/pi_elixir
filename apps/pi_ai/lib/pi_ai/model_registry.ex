defmodule PiAi.ModelRegistry do
  @moduledoc """
  Persistent model registry that saves/loads model metadata from disk.

  Combines models from all loaded providers and stores them
  in a JSON file for fast startup and offline access.
  """

  @default_path Path.expand("~/.pi/agent/models.json")

  @doc """
  Lists all registered models.
  """
  @spec list() :: [PiAi.Model.t()]
  def list, do: load()

  @doc """
  Loads the model registry from disk, falling back to provider discovery.
  """
  @spec load(String.t() | nil) :: [PiAi.Model.t()]
  def load(custom_path \\ nil) do
    path = custom_path || @default_path

    case File.read(path) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, data} -> deserialize_models(data["models"] || [])
          {:error, _} -> refresh_and_save(path)
        end

      {:error, _} ->
        refresh_and_save(path)
    end
  end

  @doc """
  Refreshes the registry from all loaded providers and saves to disk.
  """
  @spec refresh_and_save(String.t() | nil) :: [PiAi.Model.t()]
  def refresh_and_save(custom_path \\ nil) do
    path = custom_path || @default_path
    models = PiAi.Providers.all_models()
    serialized = %{"models" => serialize_models(models), "updated_at" => DateTime.utc_now() |> DateTime.to_iso8601()}

    File.mkdir_p!(Path.dirname(path))
    File.write!(path, JSON.encode!(serialized))
    models
  end

  @doc """
  Finds models matching a search query (by id, name, or provider).
  """
  @spec search(String.t(), String.t() | nil) :: [PiAi.Model.t()]
  def search(query, custom_path \\ nil) do
    models = load(custom_path)
    q = String.downcase(query)

    Enum.filter(models, fn m ->
      String.downcase(m.id) =~ q or
        (m.name && String.downcase(m.name) =~ q) or
        String.downcase(m.provider) =~ q
    end)
  end

  defp serialize_models(models) do
    Enum.map(models, fn m ->
      %{
        "id" => m.id,
        "name" => m.name,
        "provider" => m.provider,
        "api" => m.api,
        "context_window" => m.context_window,
        "max_tokens" => m.max_tokens,
        "input_cost" => m.input_cost,
        "output_cost" => m.output_cost,
        "reasoning" => m.reasoning
      }
    end)
  end

  defp deserialize_models(data) do
    Enum.map(data, fn d ->
      %PiAi.Model{
        id: d["id"] || "",
        name: d["name"],
        provider: d["provider"] || "",
        api: d["api"] || "",
        context_window: d["context_window"] || 0,
        max_tokens: d["max_tokens"] || 0,
        input_cost: d["input_cost"] || 0.0,
        output_cost: d["output_cost"] || 0.0,
        reasoning: d["reasoning"] || false
      }
    end)
  end
end
