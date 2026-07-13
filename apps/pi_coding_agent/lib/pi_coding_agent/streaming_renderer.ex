defmodule PiCodingAgent.StreamingRenderer do
  @moduledoc "Renders LLM tokens as they stream in, character by character."
  use GenServer

  defstruct [:pid, :buffer, :position, :height, :width, message_count: 0]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(_opts) do
    {:ok, cols} = case :io.columns() do {:ok, c} -> {:ok, c}; _ -> {:ok, 80} end
    {:ok, %__MODULE__{buffer: "", position: 0, height: 10, width: cols}}
  end

  def start_frame(pid, message_idx) do
    GenServer.cast(pid, {:start_frame, message_idx})
  end

  def stream_token(pid, token) do
    GenServer.cast(pid, {:token, token})
  end

  def end_frame(pid) do
    GenServer.cast(pid, :end_frame)
  end

  def handle_cast({:start_frame, msg_idx}, state) do
    IO.write(:stderr, PiTui.Terminal.clear_line() <> "\e[1G")
    {:noreply, %{state | buffer: "", position: 0, message_count: msg_idx}}
  end

  def handle_cast({:token, token}, state) do
    IO.write(:stderr, PiTui.Terminal.styled(token, :dim))
    {:noreply, %{state | buffer: state.buffer <> token, position: state.position + String.length(token)}}
  end

  def handle_cast(:end_frame, state) do
    IO.write(:stderr, "\n")
    {:noreply, %{state | buffer: ""}}
  end
end
