defmodule PiCodingAgent.Core.Keybindings do
  @moduledoc "Keybinding definitions for the coding agent."
  defstruct [:bindings]

  def new do
    bindings = %{
      enter: :submit,
      ctrl_o: :new_line,
      ctrl_a: :cursor_start,
      ctrl_e: :cursor_end,
      ctrl_u: :kill_line,
      ctrl_k: :kill_to_end,
      ctrl_y: :yank,
      ctrl_w: :delete_word,
      ctrl_z: :undo,
      alt_z: :redo,
      ctrl_l: :clear,
      ctrl_c: :interrupt,
      ctrl_d: :eof,
      ctrl_p: :history_up,
      ctrl_n: :history_down,
      alt_b: :word_backward,
      alt_f: :word_forward,
      page_up: :scroll_up,
      page_down: :scroll_down,
      ctrl_shift_s: :save_session,
      ctrl_shift_r: :load_session,
      escape: :cancel
    }
    %__MODULE__{bindings: bindings}
  end

  def resolve(%__MODULE__{bindings: bindings}, key) do
    Map.get(bindings, key, :char)
  end

  def rebind(%__MODULE__{bindings: bindings} = kb, key, action) do
    %{kb | bindings: Map.put(bindings, key, action)}
  end

  def list_actions(%__MODULE__{bindings: bindings}) do
    bindings |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
  end
end
