defmodule PiCodingAgent.CLI do
  @moduledoc """
  CLI argument parsing for the coding agent.

  Uses Elixir's built-in OptionParser for argument parsing.
  """

  @doc """
  Parses command-line arguments into a map of options.

  Supports:
    - `-p`, `--print` — single prompt mode
    - `--model` — model to use
    - `--help` — show help
    - `-v`, `--version` — show version
  """
  @spec parse_args([String.t()]) :: map()
  def parse_args(args) do
    {parsed, _rest, _invalid} =
      OptionParser.parse(args,
        switches: [
          print: :string,
          model: :string,
          help: :boolean,
          version: :boolean
        ],
        aliases: [p: :print, v: :version]
      )

    Map.new(parsed)
  end

  @doc """
  Main entry point.
  """
  def main(args) do
    opts = parse_args(args)

    cond do
      opts[:help] ->
        print_help()
        :ok

      opts[:version] ->
        print_version()
        :ok

      opts[:print] ->
        run_print_mode(opts)

      true ->
        print_help()
        :ok
    end
  end

  defp print_help do
    IO.puts(:stderr, """
    pi — Coding Agent

    Usage:
      pi -p "your prompt"   Run a single prompt and print the response
      pi --model claude     Specify a model
      pi --help             Show this help
      pi --version          Show version
    """)
  end

  defp print_version do
    IO.puts(:stderr, "pi coding agent 0.1.0")
  end

  defp run_print_mode(opts) do
    model_id = opts[:model] || "gpt-4o"
    prompt = opts[:print]

    # Find a matching model from available providers
    model = find_model(model_id)

    case model do
      {:ok, model} ->
        message = %PiAi.Message{role: :user, content: prompt}

        case PiCodingAgent.Mode.Print.run([message], model: model) do
          {:ok, _messages} -> :ok
          {:error, reason} -> IO.puts(:stderr, "Error: #{reason}")
        end

      {:error, reason} ->
        IO.puts(:stderr, "Error: #{reason}")
    end
  end

  defp find_model(model_id) do
    all_models =
      PiAi.Provider.Anthropic.models() ++
        PiAi.Provider.OpenAI.models() ++
        PiAi.Provider.Gemini.models()

    case Enum.find(all_models, &(&1.id == model_id)) do
      nil -> {:error, "Model not found: #{model_id}"}
      model -> {:ok, model}
    end
  end
end
