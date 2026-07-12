defmodule PiTui.Component.Footer do
  @moduledoc """
  Terminal footer bar showing model, status, and context info.
  """

  @doc """
  Renders a footer line with the given state information.
  """
  @spec render(keyword()) :: String.t()
  def render(opts) do
    model = Keyword.get(opts, :model, "?")
    status = Keyword.get(opts, :status, :idle)
    messages = Keyword.get(opts, :messages, 0)
    tokens = Keyword.get(opts, :tokens, 0)
    {_rows, cols} = PiTui.Terminal.size()

    status_text = case status do
      :idle -> ""
      :streaming -> PiTui.Terminal.styled(" ⟳", :yellow)
      :error -> PiTui.Terminal.styled(" ⚠", :red)
      _ -> ""
    end

    left = "#{PiTui.Terminal.styled(" pi ", :reverse)} #{PiTui.Terminal.styled(model, :cyan)}#{status_text} "
    right = " msgs:#{messages} tok:#{tokens} "
    padding = cols - String.length(PiTui.Terminal.styled(left, :reset) <> right) - 2

    if padding > 0 do
      left <> String.duplicate(" ", padding) <> PiTui.Terminal.styled(right, :dim)
    else
      left
    end
  end

  @doc """
  Renders a status message line.
  """
  @spec status_line(String.t()) :: String.t()
  def status_line(text) do
    {_rows, cols} = PiTui.Terminal.size()
    padded = String.pad_trailing(text, cols - 1)
    PiTui.Terminal.styled(padded, :dim)
  end
end
