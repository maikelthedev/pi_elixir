defmodule PiCodingAgent.Mode.RPC do
  @moduledoc """
  RPC mode — receives JSON-RPC requests on stdin and responds on stdout.

  Used for editor integrations and automated workflows.
  Supports: ping, chat, tools, execute_tool
  """

  alias PiAi.Message

  @doc """
  Processes a single JSON-RPC request.
  """
  @spec handle_request(map()) :: map()
  def handle_request(%{"method" => "ping", "id" => id}) do
    %{"jsonrpc" => "2.0", "id" => id, "result" => "pong"}
  end

  def handle_request(%{"method" => "chat", "params" => params, "id" => id}) do
    prompt = params["prompt"] || params["message"] || ""
    model_id = params["model"] || "gpt-4o"

    case PiAi.Providers.find_model(model_id) do
      {:ok, model} ->
        messages = [%Message{role: :user, content: prompt}]

        result =
          case model.api do
            "anthropic-messages" -> PiAi.Provider.Anthropic.stream_chat(model, messages, [])
            "openai-responses" -> PiAi.Provider.OpenAI.stream_chat(model, messages, [])
            "google-generative-ai" -> PiAi.Provider.Gemini.stream_chat(model, messages, [])
            _ -> PiAi.Provider.OpenAICompat.stream_chat("https://api.openai.com/v1/chat/completions", model, messages, [], model.provider)
          end

        case result do
          {:ok, [response]} ->
            %{"jsonrpc" => "2.0", "id" => id, "result" => %{"content" => response["content"] || ""}}
          {:error, reason} ->
            %{"jsonrpc" => "2.0", "id" => id, "error" => %{"code" => -32000, "message" => inspect(reason)}}
        end

      {:error, reason} ->
        %{"jsonrpc" => "2.0", "id" => id, "error" => %{"code" => -32001, "message" => reason}}
    end
  end

  def handle_request(%{"method" => "tools", "id" => id}) do
    models = PiAi.Providers.all_models()
    tool_list = Enum.map(models, &%{"id" => &1.id, "name" => &1.name, "provider" => &1.provider})
    %{"jsonrpc" => "2.0", "id" => id, "result" => tool_list}
  end

  def handle_request(%{"method" => "execute_tool", "params" => params, "id" => id}) do
    tool_name = String.to_atom(params["name"])
    args = params["arguments"] || %{}

    case PiAgent.Tool.Registry.lookup(tool_name) do
      {:ok, module} ->
        case module.call(args, %{}) do
          {:ok, result} ->
            %{"jsonrpc" => "2.0", "id" => id, "result" => %{"output" => result}}
          {:error, reason} ->
            %{"jsonrpc" => "2.0", "id" => id, "error" => %{"code" => -32002, "message" => inspect(reason)}}
        end

      :error ->
        %{"jsonrpc" => "2.0", "id" => id, "error" => %{"code" => -32003, "message" => "Unknown tool: #{tool_name}"}}
    end
  end

  def handle_request(%{"id" => id}) do
    %{"jsonrpc" => "2.0", "id" => id, "error" => %{"code" => -32601, "message" => "Method not found"}}
  end

  @doc """
  Runs RPC mode: reads JSON-RPC from stdin line by line.
  """
  def run do
    IO.puts(:stderr, "pi RPC mode started")
    IO.read(:stdio, :line)
    |> String.trim()
    |> case do
      "" -> :ok
      line ->
        case JSON.decode(line) do
          {:ok, request} ->
            response = handle_request(request)
            IO.puts(JSON.encode!(response))
          {:error, _} ->
            IO.puts(JSON.encode!(%{"jsonrpc" => "2.0", "error" => %{"code" => -32700, "message" => "Parse error"}}))
        end
        run()
    end
  end
end
