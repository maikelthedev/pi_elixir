defmodule PiTui.Keybindings do
  @moduledoc "Keybinding system for the TUI. Maps keys to actions."

  defstruct [:bindings]

  @type action :: atom() | {atom(), term()}
  @type t :: %__MODULE__{bindings: %{required(PiTui.Keys.key()) => action()}}

  def new(defaults \\ default_bindings()), do: %__MODULE__{bindings: defaults}

  def default_bindings do
    %{
      {:ctrl, ?c} => :quit,
      {:ctrl, ?d} => :delete_char,
      {:ctrl, ?f} => :cursor_right,
      {:ctrl, ?b} => :cursor_left,
      {:ctrl, ?p} => :cursor_up,
      {:ctrl, ?n} => :cursor_down,
      {:ctrl, ?a} => :cursor_home,
      {:ctrl, ?e} => :cursor_end,
      {:ctrl, ?k} => :kill_line,
      {:ctrl, ?y} => :yank,
      {:ctrl, ?u} => :kill_to_start,
      {:ctrl, ?w} => :kill_word_backward,
      {:ctrl, ?/} => :undo,
      {:ctrl, ?\s} => :redo,
      {:alt, ?f} => :word_forward,
      {:alt, ?b} => :word_backward,
      {:alt, ?d} => :kill_word_forward,
      {:alt, ?\b} => :kill_word_backward,
      :enter => :submit,
      :tab => :complete,
      :backspace => :delete_before,
      :delete => :delete_after,
      :up => :history_prev,
      :down => :history_next,
      :left => :cursor_left,
      :right => :cursor_right,
      :home => :cursor_home,
      :end => :cursor_end,
      :page_up => :page_up,
      :page_down => :page_down,
    }
  end

  def resolve(%__MODULE__{bindings: bindings}, key), do: Map.get(bindings, key, :char)

  def rebind(%__MODULE__{bindings: bindings} = kb, key, action) do
    %{kb | bindings: Map.put(bindings, key, action)}
  end
end
