defmodule PiCodingAgent.Component.OAuthSelector do
  @moduledoc "OAuth login selector."
  def render(providers \\ ~w(anthropic openai github-copilot google), selected \\ 0) do
    header = PiTui.Terminal.styled(" OAuth Login (↑↓ nav, Enter select, Esc cancel)", :reverse)
    items = Enum.with_index(providers) |> Enum.map(fn {p, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      name = PiCodingAgent.ProviderDisplayNames.name(p)
      "#{prefix} #{name} #{PiTui.Terminal.styled("(#{p})", :dim)}"
    end)
    [header] ++ items
  end
end
