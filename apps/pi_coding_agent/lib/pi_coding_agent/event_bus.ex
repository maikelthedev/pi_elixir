defmodule PiCodingAgent.EventBus do
  @moduledoc """
  Event bus for extension communication and lifecycle events.

  Provides pub/sub for agent events: turn start/end, message send/receive,
  tool calls, session changes, and errors. Extensions subscribe to events
  and react accordingly.
  """

  use GenServer

  defstruct [:subscriptions, history_size: 100, history: []]

  @type event_type ::
    :turn_start | :turn_end |
    :message_sent | :message_received |
    :tool_call | :tool_result |
    :session_start | :session_end |
    :model_changed | :compaction_done |
    :error | :custom

  @type event :: %{type: event_type(), data: term(), timestamp: integer()}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(_opts) do
    {:ok, %__MODULE__{subscriptions: %{}}}
  end

  @doc "Subscribes a pid to an event type. Use :all for all events."
  def subscribe(pid, type \\ :all) do
    GenServer.call(__MODULE__, {:subscribe, pid, type})
  end

  @doc "Unsubscribes a pid."
  def unsubscribe(pid) do
    GenServer.call(__MODULE__, {:unsubscribe, pid})
  end

  @doc "Emits an event to all subscribers."
  def emit(type, data) do
    GenServer.cast(__MODULE__, {:emit, type, data})
  end

  @doc "Returns recent events from history."
  def history(count \\ 10) do
    GenServer.call(__MODULE__, {:history, count})
  end

  @impl true
  def handle_call({:subscribe, pid, type}, _from, state) do
    current = Map.get(state.subscriptions, pid, [])
    new_subs = Map.put(state.subscriptions, pid, [type | current] |> Enum.uniq())
    Process.monitor(pid)
    {:reply, :ok, %{state | subscriptions: new_subs}}
  end

  def handle_call({:unsubscribe, pid}, _from, state) do
    {:reply, :ok, %{state | subscriptions: Map.delete(state.subscriptions, pid)}}
  end

  def handle_call({:history, count}, _from, state) do
    {:reply, Enum.take(state.history, count), state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:emit, type, data}, state) do
    event = %{type: type, data: data, timestamp: DateTime.utc_now() |> DateTime.to_unix()}
    history = [event | state.history] |> Enum.take(state.history_size)

    Enum.each(state.subscriptions, fn {pid, types} ->
      if :all in types or type in types do
        send(pid, {:pi_event, event})
      end
    end)

    {:noreply, %{state | history: history}}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {:noreply, %{state | subscriptions: Map.delete(state.subscriptions, pid)}}
  end
end
