defmodule PiCodingAgent.Component.ShowImagesSelector do
  @moduledoc "Toggle for image display in chat."
  def render(enabled \\ false) do
    status = if enabled, do: PiTui.Terminal.styled("ON", :green), else: PiTui.Terminal.styled("OFF", :red)
    "  Show images in chat: #{status}  #{PiTui.Terminal.styled("(toggle with /images)", :dim)}"
  end
end
