defmodule PiTui.SyntaxHighlight do
  @moduledoc """
  Simple syntax highlighting for terminal output.

  Supports common languages with keyword, string, comment,
  number, and type token coloring.
  """

  @keywords %{
    elixir: ~w(def defp defmodule do end if else case cond when true false nil module use import alias for with try rescue catch raise throw receive send spawn fn |> -> & << >>),
    typescript: ~w(const let var function return if else for while class interface type enum extends implements import export from default async await true false null undefined),
    javascript: ~w(const let var function return if else for while class extends import export default async await true false null undefined),
    python: ~w(def class if elif else for while return import from as try except finally with True False None def return),
    go: ~w(func var const if else for range return import package type struct interface map chan go defer select case default),
    rust: ~w(fn let mut if else for while loop match return impl struct enum trait use mod pub async await true false),
    ruby: ~w(def class if elsif else end do while for each return module include extend require true false nil),
    shell: ~w(if then else fi for do done while case esac function export local set echo exit return),
    yaml: nil,
    json: nil,
    markdown: nil,
    html: nil,
    css: nil,
  }

  @doc "Highlights source code for the given language, returning ANSI-formatted lines."
  def highlight(code, language) do
    lang = normalize_language(language)
    keywords = Map.get(@keywords, lang, [])

    code
    |> String.split("\n")
    |> Enum.map(fn line -> highlight_line(line, lang, keywords) end)
  end

  defp normalize_language("ex"), do: :elixir
  defp normalize_language("exs"), do: :elixir
  defp normalize_language("ts"), do: :typescript
  defp normalize_language("tsx"), do: :typescript
  defp normalize_language("js"), do: :javascript
  defp normalize_language("jsx"), do: :javascript
  defp normalize_language("py"), do: :python
  defp normalize_language("rb"), do: :ruby
  defp normalize_language("rs"), do: :rust
  defp normalize_language("go"), do: :go
  defp normalize_language("sh"), do: :shell
  defp normalize_language("bash"), do: :shell
  defp normalize_language("yaml"), do: :yaml
  defp normalize_language("yml"), do: :yaml
  defp normalize_language("html"), do: :html
  defp normalize_language("css"), do: :css
  defp normalize_language("json"), do: :json
  defp normalize_language("md"), do: :markdown
  defp normalize_language(""), do: :text
  defp normalize_language(_), do: :text

  defp highlight_line(line, :yaml, _kw), do: highlight_yaml(line)
  defp highlight_line(line, :json, _kw), do: highlight_value(line)
  defp highlight_line(line, :html, _kw), do: highlight_html(line)
  defp highlight_line(line, :css, _kw), do: highlight_css(line)
  defp highlight_line(line, _lang, keywords), do: highlight_generic(line, keywords)

  defp highlight_generic(line, keywords) do
    line
    |> highlight_strings()
    |> highlight_comments()
    |> highlight_numbers()
    |> highlight_keywords(keywords)
  end

  defp highlight_strings(line) do
    line
    |> replace_group(~r/"[^"]*"/, &PiTui.Terminal.styled(&1, :green))
    |> replace_group(~r/'[^']*'/, &PiTui.Terminal.styled(&1, :green))
    |> replace_group(~r/`[^`]*`/, &PiTui.Terminal.styled(&1, :yellow))
  end

  defp highlight_comments(line) do
    replace_group(line, ~r/#[^"'\n]*$/, &PiTui.Terminal.styled(&1, :dim))
  end

  defp highlight_numbers(line) do
    replace_group(line, ~r/\b\d+\.?\d*\b/, &PiTui.Terminal.styled(&1, :magenta))
  end

  defp highlight_keywords(line, keywords) do
    Enum.reduce(keywords, line, fn kw, acc ->
      replace_group(acc, ~r/\b#{kw}\b/, &PiTui.Terminal.styled(&1, :cyan))
    end)
  end

  defp highlight_yaml(line) do
    line
    |> replace_group(~r/^[\w_\/.]+(?=:)/, &PiTui.Terminal.styled(&1, :yellow))
    |> replace_group(~r/:\s/, fn m -> m end)
    |> highlight_strings()
    |> highlight_comments()
  end

  defp highlight_html(line) do
    line
    |> replace_group(~r/<\/?[\w-]+/, &PiTui.Terminal.styled(&1, :blue))
    |> replace_group(~r/"[^"]*"/, &PiTui.Terminal.styled(&1, :green))
    |> replace_group(~r/<\/?[\w-]+/, &PiTui.Terminal.styled(&1, :blue))
  end

  defp highlight_css(line) do
    line
    |> replace_group(~r/[\w-]+(?=\s*:)/, &PiTui.Terminal.styled(&1, :yellow))
    |> replace_group(~r/#[\w-]+/, &PiTui.Terminal.styled(&1, :cyan))
    |> replace_group(~r/\.[\w-]+/, &PiTui.Terminal.styled(&1, :magenta))
  end

  @doc "Simple value highlighter for JSON-like data."
  def highlight_value(line) do
    line
    |> replace_group(~r/"[^"]*"/, &PiTui.Terminal.styled(&1, :green))
    |> replace_group(~r/\btrue|false|null\b/, &PiTui.Terminal.styled(&1, :yellow))
    |> replace_group(~r/\b\d+\.?\d*\b/, &PiTui.Terminal.styled(&1, :magenta))
  end

  defp replace_group(text, regex, styler) do
    Regex.replace(regex, text, fn match -> styler.(match) end)
  end
end
