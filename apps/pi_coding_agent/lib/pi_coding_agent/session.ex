defmodule PiCodingAgent.Session do
  @moduledoc """
  Session persistence for agent conversations.

  Saves and loads conversation history as JSON files in
  ~/.pi/agent/sessions/ directory.
  """

  alias PiAi.Message

  @session_dir Path.expand("~/.pi/agent/sessions")

  @doc """
  Saves a conversation session to disk.

  Returns the session ID (timestamp-based).
  """
  @spec save([Message.t()], keyword()) :: String.t()
  def save(messages, opts \\ []) do
    session_id = Keyword.get(opts, :session_id, generate_id())
    File.mkdir_p!(@session_dir)

    data = %{
      "session_id" => session_id,
      "timestamp" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "messages" => Enum.map(messages, &serialize_message/1)
    }

    path = Path.join(@session_dir, "#{session_id}.json")
    File.write!(path, JSON.encode!(data))
    session_id
  end

  @doc """
  Loads a conversation session from disk.
  """
  @spec load(String.t()) :: {:ok, [Message.t()], map()} | {:error, term()}
  def load(session_id) do
    path = Path.join(@session_dir, "#{session_id}.json")

    case File.read(path) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, data} ->
            messages = Enum.map(data["messages"] || [], &deserialize_message/1)
            {:ok, messages, data}

          {:error, _} = err ->
            err
        end

      {:error, _} = err ->
        err
    end
  end

  @doc """
  Lists all saved sessions, newest first.
  """
  @spec list() :: [map()]
  def list do
    case File.ls(@session_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".json"))
        |> Enum.map(fn f ->
          path = Path.join(@session_dir, f)
          case File.read(path) do
            {:ok, content} ->
              case JSON.decode(content) do
                {:ok, data} -> data
                _ -> %{"session_id" => f}
              end
            _ -> %{"session_id" => f}
          end
        end)
        |> Enum.sort_by(&(&1["timestamp"] || ""), :desc)

      {:error, _} ->
        []
    end
  end

  @doc """
  Deletes a session.
  """
  @spec delete(String.t()) :: :ok
  def delete(session_id) do
    path = Path.join(@session_dir, "#{session_id}.json")
    File.rm(path)
    :ok
  end

  defp generate_id do
    "session_#{DateTime.utc_now() |> DateTime.to_unix()}_#{:erlang.unique_integer([:positive])}"
  end

  defp serialize_message(%Message{role: role, content: content} = msg) do
    %{
      "role" => Atom.to_string(role),
      "content" => content,
      "tool_calls" => msg.tool_calls,
      "tool_call_id" => msg.tool_call_id,
      "name" => msg.name,
      "is_error" => msg.is_error
    }
  end

  defp deserialize_message(data) do
    %Message{
      role: String.to_existing_atom(data["role"]),
      content: data["content"],
      tool_calls: data["tool_calls"],
      tool_call_id: data["tool_call_id"],
      name: data["name"],
      is_error: data["is_error"] || false
    }
  end
end
