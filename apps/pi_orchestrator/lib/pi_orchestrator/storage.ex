defmodule PiOrchestrator.Storage do
  @moduledoc "Session state persistence for the orchestrator."
  @base_dir Path.expand("~/.pi/orchestrator")

  def save_session(instance_id, data) do
    File.mkdir_p!(@base_dir)
    File.write!(Path.join(@base_dir, "#{instance_id}.json"), JSON.encode!(data))
  end

  def load_session(instance_id) do
    case File.read(Path.join(@base_dir, "#{instance_id}.json")) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, data} -> {:ok, data}
          err -> err
        end
      err -> err
    end
  end

  def list_sessions do
    case File.ls(@base_dir) do
      {:ok, files} -> Enum.filter(files, &String.ends_with?(&1, ".json"))
      {:error, _} -> []
    end
  end

  def delete_session(instance_id) do
    File.rm(Path.join(@base_dir, "#{instance_id}.json"))
    :ok
  end
end
