defmodule PiCodingAgent.Extension do
  @moduledoc """
  Extension system for loading custom tools from configuration.

  Extensions are Elixir modules that implement PiAgent.Tool behaviour.
  They can be loaded from ~/.pi/agent/extensions/ or project-local .pi/extensions/.
  """

  @doc """
  Loads all extensions from the configured directories.
  Returns a list of {name, module} tuples.
  """
  @spec load_all(keyword()) :: [{atom(), module()}]
  def load_all(opts \\ []) do
    dirs = [
      Keyword.get(opts, :project_dir, ".pi/extensions"),
      Path.expand("~/.pi/agent/extensions")
    ]

    dirs
    |> Enum.flat_map(&load_from_dir/1)
    |> Enum.uniq_by(fn {name, _mod} -> name end)
  end

  @doc """
  Loads extension files from a single directory.
  """
  @spec load_from_dir(String.t()) :: [{atom(), module()}]
  def load_from_dir(dir) do
    case File.ls(dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".ex"))
        |> Enum.map(fn file ->
          path = Path.join(dir, file)
          load_file(path)
        end)
        |> Enum.filter(& &1)

      {:error, _} ->
        []
    end
  end

  @doc """
  Loads a single extension file and extracts tool name.
  Returns {name, module} or nil.
  """
  @spec load_file(String.t()) :: {atom(), module()} | nil
  def load_file(path) do
    case Code.require_file(path) do
      [module] when is_atom(module) ->
        name = module |> Atom.to_string() |> String.split(".") |> List.last() |> Macro.underscore() |> String.to_atom()
        if function_exported?(module, :call, 2) and function_exported?(module, :schema, 0) do
          {name, module}
        else
          nil
        end
      _ ->
        nil
    end
  rescue
    _ -> nil
  end

  @doc """
  Registers all loaded extensions into the given registry.
  """
  @spec register_all(PiAgent.Tool.Registry.t()) :: :ok
  def register_all(registry \\ PiAgent.Tool.Registry) do
    extensions = load_all()

    Enum.each(extensions, fn {name, mod} ->
      PiAgent.Tool.Registry.register(name, mod, registry)
    end)

    :ok
  end

  @doc """
  Returns a list of extension source directories.
  """
  @spec dirs(keyword()) :: [String.t()]
  def dirs(opts \\ []) do
    base = Keyword.get(opts, :project_dir, ".pi/extensions")
    [Path.expand("~/.pi/agent/extensions")]
    |> then(fn list ->
      if File.dir?(base), do: [base | list], else: list
    end)
  end
end
