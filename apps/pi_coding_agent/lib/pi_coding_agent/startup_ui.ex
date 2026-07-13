defmodule PiCodingAgent.StartupUI do
  @moduledoc "First-time setup and startup model selector."

  @spec run() :: {:ok, PiAi.Model.t()}
  def run do
    models = PiAi.Providers.all_models()

    cond do
      !setup_done?() ->
        PiTui.Terminal.enter_raw!()
        model = show_initial_setup(models)
        PiTui.Terminal.exit_raw!()
        mark_setup_done()
        {:ok, model}

      true ->
        PiTui.Terminal.enter_raw!()
        model = show_model_selector(models)
        PiTui.Terminal.exit_raw!()
        {:ok, model}
    end
  end

  defp show_initial_setup(models) do
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    IO.write(:stderr, PiTui.Terminal.hide_cursor())
    IO.puts(:stderr, PiTui.Terminal.styled("  Welcome to pi — Coding Agent", :bold))
    IO.puts(:stderr, PiTui.Terminal.styled("  ============================", :dim))
    IO.puts(:stderr, "")
    IO.puts(:stderr, "  Select your default model:")
    show_and_select(models)
  end

  defp show_model_selector(models) do
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    IO.write(:stderr, PiTui.Terminal.hide_cursor())
    IO.puts(:stderr, PiTui.Terminal.styled("  Select a model:", :bold))
    IO.puts(:stderr, "")
    show_and_select(models)
  end

  defp show_and_select(models, selected \\ 0, top \\ 0)
  defp show_and_select(models, selected, top) do
    list_models(models, selected, top)
    wait_for_input(models, selected, top)
  end

  defp wait_for_input(models, selected, top) do
    max_visible = 15
    case IO.getn(:stdio, "", 1) do
      "\n" ->
        PiTui.Terminal.exit_raw!()
        IO.write(:stderr, PiTui.Terminal.show_cursor())
        Enum.at(models, selected) || hd(models)

      "\e[A" ->
        new_sel = max(0, selected - 1)
        new_top = if new_sel < top, do: new_sel, else: top
        list_models(models, new_sel, new_top)
        wait_for_input(models, new_sel, new_top)

      "\e[B" ->
        new_sel = min(selected + 1, length(models) - 1)
        new_top = if new_sel >= top + max_visible, do: new_sel - max_visible + 1, else: top
        list_models(models, new_sel, new_top)
        wait_for_input(models, new_sel, new_top)

      "\x03" ->
        PiTui.Terminal.exit_raw!()
        IO.write(:stderr, PiTui.Terminal.clear_screen())
        exit(:normal)

      _ ->
        wait_for_input(models, selected, top)
    end
  end

  defp list_models(models, selected, top, max_visible \\ 15) do
    visible = Enum.slice(models, top, max_visible)
    lines = Enum.map(visible, fn m ->
      prefix = if m == Enum.at(models, selected), do: " #{PiTui.Terminal.styled(">", :cyan)} ", else: "   "
      "#{prefix}#{m.id}  #{PiTui.Terminal.styled("(#{m.provider})", :dim)}"
    end)
    Enum.each(Enum.with_index(lines), fn {line, i} ->
      IO.write(:stderr, "\e[#{5 + i};1H#{String.pad_trailing(line, 80)}\e[0K")
    end)
  end

  defp setup_done? do
    File.exists?(Path.expand("~/.pi/agent/setup_done"))
  end

  defp mark_setup_done do
    File.mkdir_p!(Path.expand("~/.pi/agent"))
    File.write!(Path.expand("~/.pi/agent/setup_done"), "done")
  end
end
