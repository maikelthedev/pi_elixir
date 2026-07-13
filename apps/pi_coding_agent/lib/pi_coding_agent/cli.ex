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
          version: :boolean,
          rpc: :boolean
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

      opts[:rpc] ->
        PiCodingAgent.Mode.RPC.run()

      opts[:print] ->
        run_print_mode(opts)

      true ->
        run_interactive_mode(opts)
    end
  end

  defp print_help do
    IO.puts(:stderr, """
    pi — Coding Agent

    Usage:
      pi                     Start interactive mode
      pi -p "your prompt"   Run a single prompt and print the response
      pi --model claude     Specify a model
      pi --rpc              RPC mode (read JSON-RPC from stdin)
      pi --help             Show this help
      pi --version          Show version
    """)
  end

  defp print_version do
    IO.puts(:stderr, "pi coding agent 0.1.0")
  end

  defp run_interactive_mode(opts) do
    model_id = opts[:model]

    model =
      case model_id do
        nil ->
          # Show startup model selector (unless setup already done)
          case PiCodingAgent.StartupUI.run() do
            {:ok, m} -> m
            _ ->
              case PiAi.Providers.find_model(PiCodingAgent.Settings.default_model()) do
                {:ok, m} -> m
                _ -> hd(PiAi.Providers.all_models())
              end
          end
        id ->
          case find_model(id) do
            {:ok, m} -> m
            {:error, reason} ->
              IO.puts(:stderr, "Error: #{reason}")
              hd(PiAi.Providers.all_models())
          end
      end

    skills = PiCodingAgent.Skills.load_all()
    system_prompt = PiCodingAgent.SystemPrompt.build(model: model.id, skills: Enum.map(skills, & &1.name))
    {:ok, _} = PiCodingAgent.EventBus.start_link(name: PiCodingAgent.EventBus)
    PiCodingAgent.EventBus.emit(:session_start, %{model: model.id})

    # Register telemetry report on exit
    System.at_exit(fn _ ->
      PiCodingAgent.Telegraf.report()
    end)

    IO.puts(:stderr, "Starting interactive mode with #{model.name}...")
    PiCodingAgent.Mode.Interactive.start_link(model: model, system_prompt: system_prompt)
    Process.sleep(:infinity)
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
    PiAi.Providers.find_model(model_id)
  end
end
