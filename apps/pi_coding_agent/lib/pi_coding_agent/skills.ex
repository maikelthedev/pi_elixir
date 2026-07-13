defmodule PiCodingAgent.Skills do
  @moduledoc """
  Skills system for loading and executing skill scripts.

  Skills are markdown files (SKILL.md) that describe how to perform
  specific tasks. They can have associated scripts (.exs for Elixir).
  Skills are loaded from ~/.pi/agent/skills/ and project .pi/skills/.
  """

  @type skill :: %{
    name: String.t(),
    description: String.t(),
    path: String.t(),
    script_path: String.t() | nil,
    content: String.t()
  }

  @doc "Discovers and loads all available skills."
  @spec load_all(keyword()) :: [skill()]
  def load_all(opts \\ []) do
    dirs = [
      Keyword.get(opts, :project_dir, ".pi/skills"),
      Path.expand("~/.pi/agent/skills")
    ]

    dirs
    |> Enum.flat_map(&discover/1)
    |> Enum.uniq_by(& &1.name)
  end

  @doc "Discovers skills in a single directory."
  @spec discover(String.t()) :: [skill()]
  def discover(dir) do
    case File.ls(dir) do
      {:ok, entries} ->
        entries
        |> Enum.filter(&File.dir?(Path.join(dir, &1)))
        |> Enum.map(fn skill_dir ->
          skill_path = Path.join([dir, skill_dir, "SKILL.md"])
          script_path = find_script(Path.join(dir, skill_dir))

          case File.read(skill_path) do
            {:ok, content} ->
              %{
                name: skill_dir,
                description: extract_description(content),
                path: skill_path,
                script_path: script_path,
                content: content
              }
            {:error, _} -> nil
          end
        end)
        |> Enum.reject(&is_nil/1)

      {:error, _} -> []
    end
  end

  @doc "Finds a skill by name."
  @spec find(String.t(), keyword()) :: skill() | nil
  def find(name, opts \\ []) do
    Enum.find(load_all(opts), &(&1.name == name))
  end

  @doc "Executes a skill's script if one exists."
  @spec execute(skill(), [String.t()]) :: {:ok, String.t()} | {:error, String.t()}
  def execute(%{script_path: nil}, _args), do: {:ok, "No script for this skill."}

  def execute(%{script_path: path}, args) do
    ext = Path.extname(path)

    case ext do
      ".exs" ->
        case System.cmd("elixir", [path | args], into: [], stderr_to_stdout: true) do
          {output, 0} -> {:ok, IO.iodata_to_binary(output)}
          {output, _code} -> {:error, IO.iodata_to_binary(output)}
        end

      ".sh" ->
        case System.cmd("sh", [path | args], into: [], stderr_to_stdout: true) do
          {output, 0} -> {:ok, IO.iodata_to_binary(output)}
          {output, _code} -> {:error, IO.iodata_to_binary(output)}
        end

       _ ->
        {:ok, "Unknown script type: #{ext}"}
    end
  end

  defp find_script(dir) do
    for ext <- [".exs", ".sh"] do
      path = Path.join(dir, "script#{ext}")
      if File.exists?(path), do: path
    end
    |> Enum.find(&(&1 != nil))
  end

  defp extract_description(content) do
    case Regex.run(~r/^# (.+)$/m, content) do
      [_, desc] -> String.trim(desc)
      nil -> String.slice(String.trim(content), 0, 80)
    end
  end
end
