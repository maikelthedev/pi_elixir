defmodule PiTui.KillRing do
  @moduledoc """
  Circular buffer for killed/deleted text (emacs-style kill ring).

  Supports yank and cycle-through-yank operations.
  """

  defstruct [:entries, index: 0, max_size: 60]

  @type t :: %__MODULE__{entries: [String.t()], index: non_neg_integer(), max_size: pos_integer()}

  @doc "Creates a new kill ring."
  def new(opts \\ []), do: %__MODULE__{entries: [], max_size: Keyword.get(opts, :max_size, 60)}

  @doc "Adds text to the kill ring."
  def kill(%__MODULE__{entries: entries, max_size: max} = kr, text) do
    new_entries = [text | entries] |> Enum.take(max)
    %{kr | entries: new_entries, index: 0}
  end

  @doc "Yanks (pastes) the most recently killed text."
  def yank(%__MODULE__{entries: []}), do: {nil, :noop}

  def yank(%__MODULE__{entries: [h | _]} = kr) do
    {h, %{kr | index: 0}}
  end

  @doc "Cycles to the next entry in the kill ring (for repeated yank-pop)."
  def yank_pop(%__MODULE__{entries: []} = kr), do: {nil, kr}

  def yank_pop(%__MODULE__{entries: entries, index: idx} = kr) do
    new_idx = rem(idx + 1, length(entries))
    {Enum.at(entries, new_idx), %{kr | index: new_idx}}
  end

  @doc "Returns all entries."
  def entries(%__MODULE__{entries: entries}), do: entries
end
