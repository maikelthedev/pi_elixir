defmodule PiCodingAgent.PackageManager do
  @moduledoc """
  Package manager for installing and managing extensions and skills.

  Supports:
    - install: download and register an extension
    - list: show installed packages
    - remove: uninstall a package
    - update: refresh a package
  """

  @install_dir Path.expand("~/.pi/agent/extensions")

  @doc """
  Handles package manager CLI commands.
  """
  def handle_command(["install", name | rest]) do
    source = case rest do
      [url] -> url
      _ -> nil
    end

    install(name, source)
  end

  def handle_command(["list"]) do
    list()
  end

  def handle_command(["remove", name]) do
    remove(name)
  end

  def handle_command(["update", name]) do
    update(name)
  end

  def handle_command(_) do
    IO.puts(:stderr, """
    Usage:
      pi package install <name> [url]   Install an extension
      pi package list                    List installed extensions
      pi package remove <name>           Remove an extension
      pi package update <name>           Update an extension
    """)
    :ok
  end

  @doc """
  Installs a package by name, optionally from a URL.
  """
  def install(name, source \\ nil) do
    File.mkdir_p!(@install_dir)
    path = Path.join(@install_dir, "#{name}.ex")

    case source do
      nil ->
        # Create stub file
        content = """
        defmodule PiExtensions.#{Macro.camelize(name)} do
          @moduledoc \"\"\"Extension: #{name}\"\"\"
          @behaviour PiAgent.Tool

          @impl true
          def call(_args, _context), do: {:ok, "Not implemented"}
          @impl true
          def schema, do: %{type: "object", properties: %{}, required: []}
        end
        """
        File.write!(path, content)
        IO.puts(:stderr, "Created stub extension: #{name}")

      url ->
        case Req.get(url) do
          {:ok, %Req.Response{status: 200, body: body}} ->
            File.write!(path, body)
            IO.puts(:stderr, "Installed #{name} from #{url}")
          {:ok, %Req.Response{status: status}} ->
            IO.puts(:stderr, "Error: HTTP #{status} downloading #{url}")
          {:error, reason} ->
            IO.puts(:stderr, "Error downloading #{url}: #{inspect(reason)}")
        end
    end

    :ok
  end

  @doc """
  Lists installed extensions.
  """
  def list do
    case File.ls(@install_dir) do
      {:ok, files} ->
        exts = Enum.filter(files, &String.ends_with?(&1, ".ex"))
        if exts == [] do
          IO.puts(:stderr, "No extensions installed.")
        else
          IO.puts(:stderr, "Installed extensions:")
          Enum.each(exts, &IO.puts(:stderr, "  #{&1}"))
        end

      {:error, _} ->
        IO.puts(:stderr, "No extensions installed.")
    end

    :ok
  end

  @doc """
  Removes an installed extension.
  """
  def remove(name) do
    path = Path.join(@install_dir, "#{name}.ex")

    case File.rm(path) do
      :ok -> IO.puts(:stderr, "Removed #{name}")
      {:error, reason} -> IO.puts(:stderr, "Error removing #{name}: #{reason}")
    end

    :ok
  end

  @doc """
  Updates an installed extension.
  """
  def update(name) do
    IO.puts(:stderr, "Update for #{name} not implemented yet (reinstall with install)")
    :ok
  end
end
