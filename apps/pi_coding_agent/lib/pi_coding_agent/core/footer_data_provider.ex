defmodule PiCodingAgent.Core.FooterDataProvider do
  @moduledoc "Provides data for the TUI footer display."
  defstruct [:model, :status, :messages, :tokens, :session_id, :elapsed_ms]

  def new(opts \\ []) do
    %__MODULE__{
      model: Keyword.get(opts, :model, ""),
      status: Keyword.get(opts, :status, :idle),
      messages: Keyword.get(opts, :messages, 0),
      tokens: Keyword.get(opts, :tokens, 0),
      session_id: Keyword.get(opts, :session_id, ""),
      elapsed_ms: Keyword.get(opts, :elapsed_ms, 0)
    }
  end

  def render(footer) do
    model_str = if footer.model != "", do: footer.model, else: "no model"
    status_str = status_to_string(footer.status)
    "#{model_str} | #{status_str} | msgs:#{footer.messages} tokens:#{footer.tokens}"
  end

  defp status_to_string(:idle), do: "idle"
  defp status_to_string(:streaming), do: "streaming"
  defp status_to_string(:thinking), do: "thinking"
  defp status_to_string(:error), do: "error"
  defp status_to_string(s), do: to_string(s)
end
