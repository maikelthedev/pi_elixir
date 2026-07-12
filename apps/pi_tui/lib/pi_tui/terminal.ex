defmodule PiTui.Terminal do
  @moduledoc """
  Terminal I/O abstraction using ANSI escape sequences.

  Provides raw mode control, cursor movement, style helpers,
  and terminal size detection.
  """

  @doc """
  Returns the terminal size as {rows, cols}.

  Falls back to {24, 80} if detection fails.
  """
  @spec size() :: {non_neg_integer(), non_neg_integer()}
  def size do
    case :io.columns() do
      {:ok, cols} ->
        case :io.rows() do
          {:ok, rows} -> {rows, cols}
          _ -> {24, cols}
        end

      _ ->
        {24, 80}
    end
  end

  @doc """
  Returns ANSI escape to clear the screen and home the cursor.
  """
  @spec clear_screen() :: String.t()
  def clear_screen, do: "\e[2J\e[H"

  @doc """
  Returns ANSI escape to move cursor up N lines.
  """
  @spec cursor_up(non_neg_integer()) :: String.t()
  def cursor_up(n), do: "\e[#{n}A"

  @doc """
  Returns ANSI escape to move cursor down N lines.
  """
  @spec cursor_down(non_neg_integer()) :: String.t()
  def cursor_down(n), do: "\e[#{n}B"

  @doc """
  Returns ANSI escape to move cursor forward N columns.
  """
  @spec cursor_forward(non_neg_integer()) :: String.t()
  def cursor_forward(n), do: "\e[#{n}C"

  @doc """
  Returns ANSI escape to move cursor backward N columns.
  """
  @spec cursor_backward(non_neg_integer()) :: String.t()
  def cursor_backward(n), do: "\e[#{n}D"

  @doc """
  Returns ANSI escape to position cursor at row r, column c (1-based).
  """
  @spec cursor_pos(non_neg_integer(), non_neg_integer()) :: String.t()
  def cursor_pos(r, c), do: "\e[#{r};#{c}H"

  @doc """
  Returns ANSI escape to hide the cursor.
  """
  @spec hide_cursor() :: String.t()
  def hide_cursor, do: "\e[?25l"

  @doc """
  Returns ANSI escape to show the cursor.
  """
  @spec show_cursor() :: String.t()
  def show_cursor, do: "\e[?25h"

  @doc """
  Returns ANSI escape to clear from cursor to end of line.
  """
  @spec clear_line() :: String.t()
  def clear_line, do: "\e[0K"

  @doc """
  Returns ANSI SGR (Select Graphic Rendition) code for a style.

  Supported styles: :reset, :bold, :dim, :italic, :underline,
  :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white,
  :bg_black, :bg_red, :bg_green, :bg_yellow, :bg_blue, :bg_magenta, :bg_cyan
  """
  @spec set_style(atom()) :: String.t()
  def set_style(:reset), do: "\e[0m"
  def set_style(:bold), do: "\e[1m"
  def set_style(:dim), do: "\e[2m"
  def set_style(:italic), do: "\e[3m"
  def set_style(:underline), do: "\e[4m"
  def set_style(:black), do: "\e[30m"
  def set_style(:red), do: "\e[31m"
  def set_style(:green), do: "\e[32m"
  def set_style(:yellow), do: "\e[33m"
  def set_style(:blue), do: "\e[34m"
  def set_style(:magenta), do: "\e[35m"
  def set_style(:cyan), do: "\e[36m"
  def set_style(:white), do: "\e[37m"
  def set_style(:bg_black), do: "\e[40m"
  def set_style(:bg_red), do: "\e[41m"
  def set_style(:bg_green), do: "\e[42m"
  def set_style(:bg_yellow), do: "\e[43m"
  def set_style(:bg_blue), do: "\e[44m"
  def set_style(:bg_magenta), do: "\e[45m"
  def set_style(:bg_cyan), do: "\e[46m"
  def set_style(:reverse), do: "\e[7m"

  @doc """
  Returns the reset style escape.
  """
  @spec reset_style() :: String.t()
  def reset_style, do: "\e[0m"

  @doc """
  Wraps text in a style, returning the styled string with reset.
  """
  @spec styled(String.t(), atom()) :: String.t()
  def styled(text, style) do
    set_style(style) <> text <> reset_style()
  end

  @doc """
  Enters raw mode (non-canonical input, no echo).
  """
  @spec enter_raw!() :: :ok
  def enter_raw! do
    # Use stty via System.cmd
    System.cmd("stty", ~c[-icanon min 1 time 0 -echo], into: :stderr)
    :ok
  end

  @doc """
  Exits raw mode (restores canonical input with echo).
  """
  @spec exit_raw!() :: :ok
  def exit_raw! do
    System.cmd("stty", ~c[icanon echo], into: :stderr)
    :ok
  end
end
