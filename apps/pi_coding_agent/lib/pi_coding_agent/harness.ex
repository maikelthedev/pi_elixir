defmodule PiCodingAgent.Harness do
  @moduledoc """
  Agent harness — manages environment, execution context,
  and communication between the agent loop and the outside world.
  """

  defstruct [:env, :session_manager, :event_bus, :telemetry,
             model: nil, skills: [], tools: [], running: false,
             prompt_templates: %{}]

  def new(opts \\ []) do
    %__MODULE__{
      env: Keyword.get(opts, :env, :node),
      session_manager: Keyword.get(opts, :session_manager),
      event_bus: Keyword.get(opts, :event_bus),
      telemetry: PiCodingAgent.Telemetry.new(),
      model: Keyword.get(opts, :model),
      skills: Keyword.get(opts, :skills, []),
      tools: Keyword.get(opts, :tools, []),
      prompt_templates: Keyword.get(opts, :prompt_templates, %{})
    }
  end

  def start(%__MODULE__{running: false} = h) do
    %{h | running: true}
  end

  def stop(%__MODULE__{running: true} = h) do
    _report = PiCodingAgent.Telemetry.report(h.telemetry)
    %{h | running: false}
  end

  def timed_run(%__MODULE__{} = h, label, fun) do
    {telem, result} = PiCodingAgent.Telemetry.timed(h.telemetry, label, fun)
    {%{h | telemetry: telem}, result}
  end
end
