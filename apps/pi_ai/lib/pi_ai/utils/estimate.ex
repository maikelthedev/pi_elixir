defmodule PiAi.Utils.Estimate do
  @moduledoc "Token estimation for messages and text."
  def estimate_tokens(text) when is_binary(text) do
    words = String.split(text, ~r/\s+/) |> length()
    chars = String.length(text)
    max(words + div(chars, 4), 1)
  end
  def estimate_tokens(_), do: 50

  def estimate_messages_tokens(messages) when is_list(messages) do
    messages |> Enum.map(&estimate_message_tokens/1) |> Enum.sum()
  end

  def estimate_message_tokens(%{content: c}) when is_binary(c), do: estimate_tokens(c) + 10
  def estimate_message_tokens(%{"content" => c}) when is_binary(c), do: estimate_tokens(c) + 10
  def estimate_message_tokens(_), do: 50

  def context_window_usage(messages, max_tokens) do
    used = estimate_messages_tokens(messages)
    {used, max_tokens - used, used / max_tokens}
  end
end
