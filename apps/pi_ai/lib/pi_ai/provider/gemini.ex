defmodule PiAi.Provider.Gemini do
  @moduledoc """
  Provider implementation for Google's Gemini API.

  Converts PiAi.Message structs to Gemini's API format and
  handles streaming via Req.
  """

  @behaviour PiAi.Provider

  @api_url "https://generativelanguage.googleapis.com/v1beta/models"

  @doc """
  Converts a `PiAi.Message` to a Gemini API content block.
  """
  @spec content_to_gemini(PiAi.Message.t()) :: map()
  def content_to_gemini(%PiAi.Message{role: :user, content: content}) do
    %{role: "user", contents: [%{parts: [%{text: content || ""}]}]}
  end

  def content_to_gemini(%PiAi.Message{role: :assistant, content: content, tool_calls: nil}) do
    %{role: "model", contents: [%{parts: [%{text: content || ""}]}]}
  end

  def content_to_gemini(%PiAi.Message{role: :assistant, content: _content, tool_calls: tool_calls}) do
    parts =
      Enum.map(tool_calls || [], fn tc ->
        func = tc["function"] || tc[:function]
        args = func["arguments"] || func[:arguments] || "{}"
        args_map = if is_binary(args), do: JSON.decode!(args), else: args

        %{
          functionCall: %{
            name: func["name"] || func[:name],
            args: args_map
          }
        }
      end)

    %{role: "model", contents: [%{parts: parts}]}
  end

  def content_to_gemini(%PiAi.Message{role: :tool, content: content, tool_call_id: _tc_id, name: name}) do
    %{
      role: "function",
      contents: [
        %{
          parts: [
            %{
              functionResponse: %{
                name: name || "",
                response: %{
                  name: name || "",
                  content: content || ""
                }
              }
            }
          ]
        }
      ]
    }
  end

  @doc """
  Extracts system instruction from the message list.

  Gemini uses a separate `system_instruction` field instead of
  a system message in the contents array.
  """
  @spec extract_system_instruction([PiAi.Message.t()]) :: {map() | nil, [PiAi.Message.t()]}
  def extract_system_instruction(messages) do
    {system_msgs, rest} = Enum.split_while(messages, &(&1.role == :system))

    instruction =
      case system_msgs do
        [] -> nil
        msgs ->
          text = msgs |> Enum.map(& &1.content) |> Enum.join("\n")
          %{parts: [%{text: text}]}
      end

    {instruction, rest}
  end

  @doc """
  Builds the full Gemini API request body from messages and options.
  """
  @spec build_request_body(PiAi.Model.t(), [PiAi.Message.t()], keyword()) :: map()
  def build_request_body(_model, messages, opts) do
    {system_instruction, llm_messages} = extract_system_instruction(messages)

    contents =
      Enum.map(llm_messages, fn msg ->
        result = content_to_gemini(msg)
        result[:contents] || result
      end)
      |> List.flatten()

    body = %{
      contents: contents
    }

    body =
      if system_instruction do
        Map.put(body, :system_instruction, system_instruction)
      else
        body
      end

    body =
      if generation_config = build_generation_config(opts) do
        Map.put(body, :generationConfig, generation_config)
      else
        body
      end

    body
  end

  @doc """
  Returns known Gemini models.
  """
  @impl true
  @spec models() :: [PiAi.Model.t()]
  def models do
    [
      %PiAi.Model{
        id: "gemini-2.5-flash",
        name: "Gemini 2.5 Flash",
        provider: "google",
        api: "google-generative-ai",
        context_window: 1_000_000,
        max_tokens: 64_000,
        input_cost: 0.15,
        output_cost: 0.60
      },
      %PiAi.Model{
        id: "gemini-2.5-pro",
        name: "Gemini 2.5 Pro",
        provider: "google",
        api: "google-generative-ai",
        context_window: 1_000_000,
        max_tokens: 64_000,
        input_cost: 1.25,
        output_cost: 10.0
      },
      %PiAi.Model{
        id: "gemini-2.0-flash",
        name: "Gemini 2.0 Flash",
        provider: "google",
        api: "google-generative-ai",
        context_window: 1_000_000,
        max_tokens: 8_192,
        input_cost: 0.10,
        output_cost: 0.40
      }
    ]
  end

  @impl PiAi.Provider
  def stream_chat(model, messages, opts) do
    body = build_request_body(model, messages, opts)
    api_key = resolve_api_key(opts)
    url = "#{@api_url}/#{model.id}:streamGenerateContent?alt=sse"

    request =
      Req.new(
        url: url,
        method: :post,
        headers: [
          {"x-goog-api-key", api_key},
          {"content-type", "application/json"}
        ],
        json: body,
        into: fn chunk, _acc ->
          {:cont, chunk}
        end
      )

    case Req.post(request) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, [body]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Gemini API error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Private helpers

  defp build_generation_config(opts) do
    config = %{}

    config =
      if temp = Keyword.get(opts, :temperature), do: Map.put(config, :temperature, temp), else: config

    config =
      if max = Keyword.get(opts, :max_tokens), do: Map.put(config, :maxOutputTokens, max), else: config

    if config == %{}, do: nil, else: config
  end

  defp resolve_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil ->
        case PiAi.Auth.load("google") do
          {:ok, %{"api_key" => key}} -> key
          _ -> System.get_env("GEMINI_API_KEY") || ""
        end

      key ->
        key
    end
  end
end
