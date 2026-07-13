defmodule PiTui.TerminalImage do
  @moduledoc "Terminal image rendering via Kitty's icat protocol or sixel."

  @doc "Returns the escape sequence to display an image file at the terminal."
  def display(path, opts \\ []) do
    width = Keyword.get(opts, :width, 60)
    height = Keyword.get(opts, :height, 30)

    case File.read(path) do
      {:ok, data} ->
        b64 = Base.encode64(data)
        "\e_Ga=T,f=100,s=#{width},v=#{height};#{b64}\e\\"

      {:error, _} ->
        "#{PiTui.Terminal.styled("[image: #{path}]", :dim)}"
    end
  end

  @doc "Returns a placeholder for images when display is not supported."
  def placeholder(path, reason \\ "not supported"), do: PiTui.Terminal.styled("[image: #{path} (#{reason})]", :dim)
end
