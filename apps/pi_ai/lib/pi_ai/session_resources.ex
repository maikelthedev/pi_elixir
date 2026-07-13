defmodule PiAi.SessionResources do
  @moduledoc "Tracks session resource usage: tokens, API calls, costs."
  defstruct [:session_id, input_tokens: 0, output_tokens: 0, api_calls: 0,
             total_cost_usd: 0.0, started_at: nil, last_call_at: nil, by_model: %{}]

  def new(session_id) do
    %__MODULE__{session_id: session_id, started_at: DateTime.utc_now()}
  end

  def record_call(resources, model, input_tokens, output_tokens) do
    cost = estimate_cost(model, input_tokens, output_tokens)
    by_model = Map.update(resources.by_model, model, %{calls: 1, input: input_tokens, output: output_tokens, cost: cost},
      fn existing -> %{existing | calls: existing.calls + 1, input: existing.input + input_tokens,
                       output: existing.output + output_tokens, cost: existing.cost + cost} end)
    %{resources |
      input_tokens: resources.input_tokens + input_tokens,
      output_tokens: resources.output_tokens + output_tokens,
      api_calls: resources.api_calls + 1,
      total_cost_usd: resources.total_cost_usd + cost,
      last_call_at: DateTime.utc_now(),
      by_model: by_model}
  end

  def summary(resources) do
    %{
      session_id: resources.session_id,
      total_tokens: resources.input_tokens + resources.output_tokens,
      input_tokens: resources.input_tokens,
      output_tokens: resources.output_tokens,
      api_calls: resources.api_calls,
      cost_usd: Float.round(resources.total_cost_usd, 6),
      by_model: resources.by_model
    }
  end

  defp estimate_cost(model, input, output) do
    {input_rate, output_rate} = rate_for(model)
    input * input_rate + output * output_rate
  end

  defp rate_for(model) do
    cond do
      String.contains?(model, "sonnet") -> {3.0 / 1_000_000, 15.0 / 1_000_000}
      String.contains?(model, "haiku") -> {0.25 / 1_000_000, 1.25 / 1_000_000}
      String.contains?(model, "opus") -> {15.0 / 1_000_000, 75.0 / 1_000_000}
      String.contains?(model, "gpt-4") -> {10.0 / 1_000_000, 30.0 / 1_000_000}
      String.contains?(model, "gemini") -> {1.25 / 1_000_000, 5.0 / 1_000_000}
      true -> {1.0 / 1_000_000, 3.0 / 1_000_000}
    end
  end
end
