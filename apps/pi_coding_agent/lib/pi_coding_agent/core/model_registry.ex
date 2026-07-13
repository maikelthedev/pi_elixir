defmodule PiCodingAgent.Core.ModelRegistry do
  @moduledoc "Model registry for coding agent - resolves model names and manages model state."
  use GenServer

  defstruct [:models, :aliases, :default_model]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    default = Keyword.get(opts, :default_model, "anthropic/claude-sonnet-4-20250514")
    aliases = default_aliases()
    {:ok, %__MODULE__{models: %{}, aliases: aliases, default_model: default}}
  end

  def resolve(input), do: GenServer.call(__MODULE__, {:resolve, input})
  def register(model_id, info \\ %{}), do: GenServer.call(__MODULE__, {:register, model_id, info})
  def default, do: GenServer.call(__MODULE__, :default)
  def list_all, do: GenServer.call(__MODULE__, :list_all)

  def handle_call({:resolve, input}, _from, state) do
    result = cond do
      Map.has_key?(state.aliases, input) -> {:ok, Map.fetch!(state.aliases, input)}
      Map.has_key?(state.models, input) -> {:ok, input}
      String.contains?(input, "/") -> {:ok, input}
      true -> search_models(input, state)
    end
    {:reply, result, state}
  end

  def handle_call({:register, model_id, info}, _from, state) do
    models = Map.put(state.models, model_id, info)
    {:reply, :ok, %{state | models: models}}
  end

  def handle_call(:default, _from, state), do: {:reply, state.default_model, state}
  def handle_call(:list_all, _from, state), do: {:reply, Map.keys(state.models), state}

  defp search_models(query, state) do
    matches = state.models |> Map.keys() |> Enum.filter(&String.contains?(&1, query))
    case matches do
      [first | _] -> {:ok, first}
      [] -> {:error, :not_found}
    end
  end

  defp default_aliases do
    %{
      "sonnet" => "anthropic/claude-sonnet-4-20250514",
      "claude" => "anthropic/claude-sonnet-4-20250514",
      "opus" => "anthropic/claude-opus-4-20250514",
      "haiku" => "anthropic/claude-haiku-4-20250514",
      "gpt4" => "openai/gpt-4.1",
      "o3" => "openai/o3",
      "o4" => "openai/o4-mini",
      "gemini" => "gemini/gemini-2.5-pro",
      "flash" => "gemini/gemini-2.5-flash",
      "deepseek" => "deepseek/deepseek-chat",
      "grok" => "xai/grok-3",
      "qwen" => "openrouter/qwen3-235b-a22b"
    }
  end
end
