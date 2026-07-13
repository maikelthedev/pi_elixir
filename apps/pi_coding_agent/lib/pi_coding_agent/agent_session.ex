defmodule PiCodingAgent.AgentSession do
  @moduledoc "Agent session management: lifecycle, state, and message handling."
  use GenServer
  require Logger
  alias PiAi.Message

  defstruct [:id, :model, :messages, :tools, :system_prompt, :config, :timings,
             :resources, status: :idle, turns: 0]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(opts) do
    id = Keyword.get(opts, :id, generate_id())
    model = Keyword.get(opts, :model, "anthropic/claude-sonnet-4-20250514")
    system_prompt = Keyword.get(opts, :system_prompt, "You are pi, a coding agent.")
    config = Keyword.get(opts, :config, %{})

    messages = [%Message{role: :system, content: system_prompt}]
    {:ok, %__MODULE__{
      id: id, model: model, messages: messages, tools: default_tools(),
      system_prompt: system_prompt, config: config,
      timings: PiCodingAgent.Timings.new(),
      resources: PiAi.SessionResources.new(id)
    }}
  end

  def send_message(pid, content) when is_binary(content) do
    GenServer.call(pid, {:send_message, content}, 60_000)
  end

  def get_messages(pid), do: GenServer.call(pid, :get_messages)
  def get_state(pid), do: GenServer.call(pid, :get_state)
  def clear_history(pid), do: GenServer.call(pid, :clear_history)

  def handle_call({:send_message, content}, _from, state) do
    user_msg = %Message{role: :user, content: content}
    messages = state.messages ++ [user_msg]
    state = %{state | messages: messages, status: :processing, turns: state.turns + 1}
    timings = PiCodingAgent.Timings.start_timer(state.timings, :last_request)

    case PiAi.Provider.chat(state.model, messages, tools: state.tools) do
      {:ok, response} ->
        messages = messages ++ [response]
        timings = PiCodingAgent.Timings.stop_timer(timings, :last_request)
        resources = PiAi.SessionResources.record_call(state.resources, state.model, 0, 0)
        state = %{state | messages: messages, status: :idle, timings: timings, resources: resources}
        {:reply, {:ok, response.content}, state}

      {:error, reason} ->
        timings = PiCodingAgent.Timings.stop_timer(timings, :last_request)
        state = %{state | status: :error, timings: timings}
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:get_messages, _from, state), do: {:reply, state.messages, state}
  def handle_call(:get_state, _from, state), do: {:reply, state, state}
  def handle_call(:clear_history, _from, state) do
    messages = [%Message{role: :system, content: state.system_prompt}]
    {:reply, :ok, %{state | messages: messages, turns: 0}}
  end

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

  defp generate_id, do: :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
end
