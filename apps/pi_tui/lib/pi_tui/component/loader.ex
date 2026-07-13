defmodule PiTui.Component.Loader do
  @moduledoc "Terminal spinner/loader animation."
  @frames ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

  @doc "Returns the nth frame of the spinner."
  def frame(n), do: Enum.at(@frames, rem(n, length(@frames)))

  @doc "Renders a spinner with a message."
  def render(msg, frame_n \\ 0), do: "#{PiTui.Terminal.styled(frame(frame_n), :cyan)} #{msg}"
end
