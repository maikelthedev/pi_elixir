defmodule PiTui.Component.CancellableLoader do
  @moduledoc "Loader with a cancel option. Shows a spinner and cancel hint."

  @frames ~w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

  @doc "Renders a cancellable loader line."
  def render(msg, frame_n \\ 0) do
    spinner = Enum.at(@frames, rem(frame_n, length(@frames)))
    "#{PiTui.Terminal.styled(spinner, :cyan)} #{msg}  #{PiTui.Terminal.styled("[Ctrl+C to cancel]", :dim)}"
  end
end
