defmodule PiTui.TUI do
  @moduledoc "Main TUI rendering framework."
  defstruct [:main_component, :footer_component, :status_component, :overlay, :input_handler, :renderer, :keybindings, width: 80, height: 24, running: false]
  @type t :: %__MODULE__{}

  def new(opts \\ []) do
    cols = case :io.columns() do {:ok, c} -> c; _ -> 80 end
    rows = case :io.rows() do {:ok, r} -> r; _ -> 24 end
    %__MODULE__{
      keybindings: PiTui.NativeModifiers.platform_bindings(),
      width: Keyword.get(opts, :width, cols),
      height: Keyword.get(opts, :height, min(rows, 24)),
      renderer: PiTui.DifferentialRenderer.new(min(rows, 24))
    }
  end

  def start(%__MODULE__{} = tui) do
    PiTui.Terminal.enter_raw!()
    IO.write(:stderr, PiTui.Terminal.hide_cursor())
    run_loop(%{tui | running: true})
  end

  def stop(%__MODULE__{} = tui) do
    IO.write(:stderr, PiTui.Terminal.show_cursor())
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    PiTui.Terminal.exit_raw!()
    %{tui | running: false}
  end

  defp run_loop(%{running: false} = tui), do: stop(tui)
  defp run_loop(tui) do
    {key, _rest} = PiTui.Keys.parse(IO.getn(:stdio, "", 1) |> IO.iodata_to_binary())
    _action = PiTui.Keybindings.resolve(tui.keybindings, key)
    {:noreply, tui}
  end

  def clear(%__MODULE__{} = tui) do
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    %{tui | renderer: PiTui.DifferentialRenderer.new(tui.height)}
  end
end
