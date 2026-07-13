defmodule PiCodingAgent.SDK do
  @moduledoc "Public SDK API for embedding pi coding agent in other applications."
  alias PiAi.Message

  @doc "Starts a new coding agent session with the given options."
  def start_session(opts \\ []) do
    model = Keyword.get(opts, :model, "anthropic/claude-sonnet-4-20250514")
    tools = Keyword.get(opts, :tools, default_tools())
    system_prompt = Keyword.get(opts, :system_prompt, default_system_prompt())
    session_id = generate_session_id()

    messages = [
      %Message{role: :system, content: system_prompt}
    ]

    {:ok, %{session_id: session_id, model: model, messages: messages, tools: tools}}
  end

  @doc "Sends a message to the session and returns the response."
  def chat(session, user_message) do
    msg = %Message{role: :user, content: user_message}
    messages = session.messages ++ [msg]

    case PiAi.Provider.chat(session.model, messages, tools: session.tools) do
      {:ok, response} ->
        messages = messages ++ [response]
        {:ok, %{session | messages: messages}, response.content}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Sends a message and returns the full message history."
  def chat_with_history(session, user_message) do
    case chat(session, user_message) do
      {:ok, session, response} -> {:ok, session, session.messages}
      error -> error
    end
  end

  @doc "Returns the message history for a session."
  def get_messages(session), do: session.messages

  @doc "Clears the message history but keeps the system prompt."
  def clear_history(session) do
    system = Enum.filter(session.messages, &(&1.role == :system))
    %{session | messages: system}
  end

  @doc "Returns available models grouped by provider."
  def list_models do
    PiAi.ModelRegistry.list()
    |> Enum.group_by(& &1.provider)
    |> Enum.map(fn {provider, models} -> {provider, Enum.map(models, & &1.id)} end)
  end

  @doc "Returns the version of the pi coding agent."
  def version, do: "0.1.0"

  defp default_tools do
    [
      %{name: "bash", description: "Execute a bash command"},
      %{name: "read", description: "Read a file"},
      %{name: "write", description: "Write content to a file"},
      %{name: "edit", description: "Edit a file"},
      %{name: "ls", description: "List directory contents"},
      %{name: "find", description: "Find files"},
      %{name: "grep", description: "Search file contents"}
    ]
  end

  defp default_system_prompt do
    "You are pi, a coding agent. You can read, write, and edit files, execute commands, and help with software development."
  end

  defp generate_session_id, do: :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
end
