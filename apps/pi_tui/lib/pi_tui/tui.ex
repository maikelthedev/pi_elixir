defmodule PiTui.TUI do
  @moduledoc """
  Main TUI rendering framework.

  Manages the full terminal lifecycle: screen buffer, cursor positioning,
  component rendering, and event dispatch.
  """

  defstruct [
    :main_component, :footer_component, :status_component,
    :overlay, :input_handler, :renderer,
    :keybindings, width: 80, height: 24, running: false
  ]

  @type t :: %__MODULE__{}

  def new(opts \\ []) do
    {:ok, cols} = :io.columns()
    {:ok, rows} = :io.rows()

    %__MODULE__{
      keybindings: PiTui.NativeModifiers.platform_bindings(),
      width: Keyword.get(opts, :width, cols),
      height: Keyword.get(opts, :height, min(rows, 24)),
      renderer: PiTui.DifferentialRenderer.new(min(rows, 24))
    }
  end

  @doc "Starts the TUI event loop."
  def start(%__MODULE__{} = tui) do
    PiTui.Terminal.enter_raw!()
    IO.write(:stderr, PiTui.Terminal.hide_cursor())
    run_loop(%{tui | running: true})
  end

  @doc "Stops the TUI and restores the terminal."
  def stop(%__MODULE__{} = tui) do
    IO.write(:stderr, PiTui.Terminal.show_cursor())
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    PiTui.Terminal.exit_raw!()
    %{tui | running: false}
  end

  defp run_loop(%{running: false} = tui), do: stop(tui)
  defp run_loop(tui) do
    {key, _rest} = PiTui.Keys.parse(IO.getn(:stdio, "", 1) |> IO.iodata_to_binary())
    action = PiTui.Keybindings.resolve(tui.keybindings, key)
    {:noreply, tui}
  end

  @doc "Clears the screen and resets the renderer."
  def clear(%__MODULE__{} = tui) do
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    %{tui | renderer: PiTui.DifferentialRenderer.new(tui.height)}
  end
end
