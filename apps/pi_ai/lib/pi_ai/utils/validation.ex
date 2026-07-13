defmodule PiAi.Utils.Validation do
  @moduledoc "Input validation for AI requests."
  def validate_model(model) when is_binary(model) do
    case String.split(model, "/", parts: 2) do
      [provider, _model] when provider != "" -> :ok
      _ -> {:error, :invalid_model_format}
    end
  end
  def validate_model(_), do: {:error, :invalid_model}

  def validate_messages([]), do: {:error, :empty_messages}
  def validate_messages(messages) when is_list(messages) do
    if Enum.all?(messages, &valid_message?/1), do: :ok, else: {:error, :invalid_message}
  end
  def validate_messages(_), do: {:error, :invalid_messages}

  def validate_temperature(t) when is_number(t) and t >= 0 and t <= 2, do: :ok
  def validate_temperature(_), do: {:error, :invalid_temperature}

  def validate_max_tokens(t) when is_integer(t) and t > 0 and t <= 1_000_000, do: :ok
  def validate_max_tokens(_), do: {:error, :invalid_max_tokens}

  defp valid_message?(%{role: r, content: c}) when r in [:user, :assistant, :system] and is_binary(c), do: true
  defp valid_message?(%{role: :tool, content: c, tool_call_id: id}) when is_binary(c) and is_binary(id), do: true
  defp valid_message?(%{"role" => r, "content" => c}) when is_binary(r) and is_binary(c), do: true
  defp valid_message?(_), do: false
end
