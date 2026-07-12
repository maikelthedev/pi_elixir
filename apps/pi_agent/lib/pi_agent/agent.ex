defmodule PiAgent.Agent do
  @moduledoc """
  A GenServer that manages an agent's conversation state.

  The agent holds a list of messages, a model configuration, and
  a reference to a Tool.Registry. It can process messages through
  the LLM and execute tool calls in response.
  """

  use GenServer

  alias PiAi.Message

  defstruct [:model, :registry, messages: [], system_prompt: "", streaming: false]

  @type t :: %__MODULE__{
          model: PiAi.Model.t(),
          registry: atom(),
          messages: [Message.t()],
          system_prompt: String.t(),
          streaming: boolean()
        }

  # Client API

  @doc """
  Starts an agent with the given options.

  Options:
    - `:model` - a `PiAi.Model` struct (required)
    - `:registry` - the tool registry name (default: `PiAgent.Tool.Registry`)
    - `:system_prompt` - optional system prompt
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, Keyword.take(opts, [:name]))
  end

  @doc """
  Adds a message to the agent's conversation history.
  """
  @spec add_message(pid(), Message.t()) :: :ok
  def add_message(pid, message) do
    GenServer.cast(pid, {:add_message, message})
  end

  @doc """
  Returns all messages in the conversation history.
  """
  @spec get_messages(pid()) :: [Message.t()]
  def get_messages(pid) do
    GenServer.call(pid, :get_messages)
  end

  @doc """
  Returns the current agent state.
  """
  @spec get_state(pid()) :: t()
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  @doc """
  Builds tool schemas from the registry for use in LLM tool definitions.
  """
  @spec build_tool_schemas(atom()) :: [map()]
  def build_tool_schemas(registry) do
    registry
    |> PiAgent.Tool.Registry.list()
    |> Enum.map(fn name ->
      {:ok, module} = PiAgent.Tool.Registry.lookup(name, registry)
      %{
        name: name,
        description: module.schema()[:description] || "",
        parameters: module.schema()
      }
    end)
  end

  # Server callbacks

  @impl true
  def init(opts) do
    state = %__MODULE__{
      model: Keyword.fetch!(opts, :model),
      registry: Keyword.get(opts, :registry, PiAgent.Tool.Registry),
      system_prompt: Keyword.get(opts, :system_prompt, ""),
      messages: [],
      streaming: false
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_messages, _from, state) do
    {:reply, state.messages, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:add_message, message}, state) do
    {:noreply, %{state | messages: state.messages ++ [message]}}
  end
end
