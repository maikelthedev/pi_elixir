defmodule PiCodingAgent.SessionManager do
  @moduledoc """
  Full session manager with branching support.

  Manages conversation entries including messages, compaction
  summaries, branch points, and metadata. Supports saving/
  loading conversation trees with parent/child relationships.
  """

  alias PiAi.Message

  defstruct [
    :session_id, :cwd, :created_at, :updated_at,
    entries: [], branches: %{}, current_branch: :main, model: nil
  ]

  @type entry_type :: :message | :compaction | :branch | :metadata

  @type t :: %__MODULE__{
    session_id: String.t(), cwd: String.t(),
    created_at: integer(), updated_at: integer(),
    entries: [map()], branches: %{atom() => [map()]},
    current_branch: atom(), model: String.t() | nil
  }

  @doc "Creates a new session manager."
  def new(opts \\ []) do
    now = DateTime.utc_now() |> DateTime.to_unix()
    %__MODULE__{
      session_id: Keyword.get(opts, :session_id, generate_id()),
      cwd: Keyword.get(opts, :cwd, File.cwd!()),
      created_at: now,
      updated_at: now,
      model: Keyword.get(opts, :model),
      entries: [],
      branches: %{main: []}
    }
  end

  @doc "Adds a message entry to the current branch."
  def add_message(%__MODULE__{branches: branches, current_branch: b} = sm, message) do
    entry = %{
      type: :message,
      timestamp: DateTime.utc_now() |> DateTime.to_unix(),
      role: message.role,
      content: message.content,
      tool_call_id: message.tool_call_id,
      name: message.name,
      is_error: message.is_error
    }

    branch_entries = (branches[b] || []) ++ [entry]
    new_branches = Map.put(branches, b, branch_entries)
    %{sm | branches: new_branches, updated_at: DateTime.utc_now() |> DateTime.to_unix()}
  end

  @doc "Adds a compaction entry."
  def add_compaction(%__MODULE__{branches: branches, current_branch: b} = sm, summary_text) do
    entry = %{
      type: :compaction,
      timestamp: DateTime.utc_now() |> DateTime.to_unix(),
      summary: summary_text
    }

    branch_entries = (branches[b] || []) ++ [entry]
    %{sm | branches: Map.put(branches, b, branch_entries)}
  end

  @doc "Creates a new branch from the current state."
  def fork(%__MODULE__{branches: branches, current_branch: b} = sm, name) do
    if Map.has_key?(branches, name) do
      {:error, "Branch #{name} already exists"}
    else
      parent_entries = branches[b] || []
      new_branches = Map.put(branches, name, parent_entries)
      {:ok, %{sm | branches: new_branches, current_branch: name}}
    end
  end

  @doc "Switches to an existing branch."
  def switch_branch(%__MODULE__{branches: branches} = sm, name) do
    if Map.has_key?(branches, name) do
      {:ok, %{sm | current_branch: name}}
    else
      {:error, "Branch #{name} not found"}
    end
  end

  @doc "Returns all messages from the current branch."
  def messages(%__MODULE__{branches: branches, current_branch: b}) do
    (branches[b] || [])
    |> Enum.filter(fn e -> entry_type_is?(e, :message) end)
    |> Enum.map(fn e ->
      %Message{
        role: entry_val(e, :role),
        content: entry_val(e, :content),
        tool_call_id: entry_val(e, :tool_call_id),
        name: entry_val(e, :name),
        is_error: entry_val(e, :is_error) || false
      }
    end)
  end

  @doc "Saves the session to disk."
  def save(%__MODULE__{} = sm, dir \\ nil) do
    session_dir = dir || Path.expand("~/.pi/agent/sessions")
    File.mkdir_p!(session_dir)
    path = Path.join(session_dir, "#{sm.session_id}.json")
    File.write!(path, JSON.encode!(%{
      session_id: sm.session_id,
      cwd: sm.cwd,
      created_at: sm.created_at,
      updated_at: sm.updated_at,
      model: sm.model,
      current_branch: sm.current_branch,
      branches: serialize_branches(sm.branches)
    }))
    :ok
  end

  @doc "Loads a session from disk."
  def load(session_id, dir \\ nil) do
    session_dir = dir || Path.expand("~/.pi/agent/sessions")
    path = Path.join(session_dir, "#{session_id}.json")

    case File.read(path) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, data} ->
            sm = %__MODULE__{
              session_id: data["session_id"],
              cwd: data["cwd"] || File.cwd!(),
              created_at: data["created_at"],
              updated_at: data["updated_at"] || data["created_at"],
              model: data["model"],
              current_branch: String.to_atom(data["current_branch"] || "main"),
              branches: deserialize_branches(data["branches"] || %{})
            }
            {:ok, sm}

          err -> err
        end

      err -> err
    end
  end

  @doc "Lists all branches."
  def list_branches(%__MODULE__{branches: branches, current_branch: current}) do
    Map.keys(branches)
    |> Enum.map(fn name ->
      count = length(branches[name] || [])
      active = if name == current, do: " (active)", else: ""
      "#{name}#{active}: #{count} entries"
    end)
  end

  defp generate_id, do: "session_#{DateTime.utc_now() |> DateTime.to_unix()}_#{:erlang.unique_integer([:positive])}"

  defp serialize_branches(branches) do
    Map.new(branches, fn {name, entries} ->
      {Atom.to_string(name), entries}
    end)
  end

  defp deserialize_branches(data) do
    Map.new(data, fn {name, entries} ->
      {String.to_atom(name), entries}
    end)
  end

  defp entry_type(e), do: e[:type] || e["type"]
  defp entry_val(e, key), do: e[key] || e[Atom.to_string(key)]

  defp entry_type_is?(e, type) do
    val = entry_type(e)
    val == type or val == Atom.to_string(type)
  end
end
