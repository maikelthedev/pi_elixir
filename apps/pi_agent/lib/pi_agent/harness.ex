defmodule PiAgent.Harness do
  @moduledoc "Agent harness — orchestrates the agent loop with session management, compaction, and skills."
  use GenServer

  defstruct [:model, :session, :skills, :prompt_templates, :env, :options,
             running: false, config: %{}, phase: :idle]

  @type t :: %__MODULE__{
    model: PiAi.Model.t(),
    session: term(),
    skills: [term()],
    prompt_templates: %{String.t() => String.t()},
    env: atom(),
    options: keyword(),
    running: boolean(),
    config: map(),
    phase: atom()
  }

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    model = Keyword.fetch!(opts, :model)
    env = Keyword.get(opts, :env, :node)
    skills = Keyword.get(opts, :skills, PiCodingAgent.Skills.load_all())
    pt = %{
      "system" => Keyword.get(opts, :system_prompt, PiCodingAgent.SystemPrompt.build(model: model.id)),
      "compact" => "Summarize the following conversation concisely:\n\n{{conversation}}"
    }
    {:ok, %__MODULE__{model: model, env: env, skills: skills, prompt_templates: pt}}
  end

  def run(pid, messages, opts \\ []) do
    GenServer.call(pid, {:run, messages, opts}, :infinity)
  end

  def handle_call({:run, messages, _opts}, _from, state) do
    result = case state.model.api do
      "anthropic-messages" -> PiAi.Provider.Anthropic.stream_chat(state.model, messages, [])
      "openai-responses" -> PiAi.Provider.OpenAI.stream_chat(state.model, messages, [])
      _ -> {:error, "Unknown API: #{state.model.api}"}
    end
    {:reply, result, %{state | phase: :completed}}
  end
end
