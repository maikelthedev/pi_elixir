defmodule PiCodingAgent.Mode.Print do
  @moduledoc """
  Print mode — executes a single prompt/response cycle and prints the result.
  """
  alias PiAi.Message

  @doc """
  Runs the print mode with the given messages and options.

  Returns `{:ok, messages}` on success or `{:error, reason}` on failure.
  """
  @spec run([Message.t()], keyword()) :: {:ok, [Message.t()]} | {:error, String.t()}
  def run(messages, opts) do
    model = Keyword.fetch!(opts, :model)

    # Call the provider's stream_chat
    case model.api do
      "anthropic-messages" ->
        case PiAi.Provider.Anthropic.stream_chat(model, messages, opts) do
          {:ok, [response]} ->
            case PiAgent.Loop.process_response(response, messages, %{}, :agent_test, :anthropic) do
              {:done, all_messages} -> {:ok, all_messages}
              {:continue, all_messages, _tool_calls} -> {:ok, all_messages}
            end

          {:error, reason} ->
            {:error, reason}
        end

      "openai-responses" ->
        case PiAi.Provider.OpenAI.stream_chat(model, messages, opts) do
          {:ok, [response]} ->
            case PiAgent.Loop.process_response(response, messages, %{}, :agent_test, :openai) do
              {:done, all_messages} -> {:ok, all_messages}
              {:continue, all_messages, _tool_calls} -> {:ok, all_messages}
            end

          {:error, reason} ->
            {:error, reason}
        end

      "google-generative-ai" ->
        case PiAi.Provider.Gemini.stream_chat(model, messages, opts) do
          {:ok, [response]} ->
            case PiAgent.Loop.process_response(response, messages, %{}, :agent_test, :gemini) do
              {:done, all_messages} -> {:ok, all_messages}
              {:continue, all_messages, _tool_calls} -> {:ok, all_messages}
            end

          {:error, reason} ->
            {:error, reason}
        end

      _ ->
        {:error, "Unknown API type: #{model.api}"}
    end
  end
end
