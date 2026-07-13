defmodule PiCodingAgent.Utils.Mime do
  @moduledoc "MIME type detection for files."
  @mime_types %{
    ".ex" => "text/x-elixir",
    ".exs" => "text/x-elixir",
    ".erl" => "text/x-erlang",
    ".js" => "text/javascript",
    ".ts" => "text/typescript",
    ".jsx" => "text/javascript",
    ".tsx" => "text/typescript",
    ".py" => "text/x-python",
    ".rb" => "text/x-ruby",
    ".go" => "text/x-go",
    ".rs" => "text/x-rust",
    ".java" => "text/x-java",
    ".c" => "text/x-c",
    ".cpp" => "text/x-c++",
    ".h" => "text/x-c",
    ".css" => "text/css",
    ".html" => "text/html",
    ".json" => "application/json",
    ".yaml" => "text/yaml",
    ".yml" => "text/yaml",
    ".toml" => "text/plain",
    ".md" => "text/markdown",
    ".txt" => "text/plain",
    ".png" => "image/png",
    ".jpg" => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".gif" => "image/gif",
    ".svg" => "image/svg+xml",
    ".pdf" => "application/pdf",
    ".zip" => "application/zip",
    ".tar" => "application/x-tar",
    ".gz" => "application/gzip",
    ".sh" => "text/x-shellscript",
    ".bash" => "text/x-shellscript",
    ".fish" => "text/x-shellscript"
  }

  def from_extension(ext) do
    ext = if String.starts_with?(ext, "."), do: ext, else: "." <> ext
    Map.get(@mime_types, ext, "application/octet-stream")
  end

  def from_path(path) do
    path |> Path.extname() |> from_extension()
  end

  def image?(mime), do: String.starts_with?(mime, "image/")
  def text?(mime), do: String.starts_with?(mime, "text/") or mime in ["application/json", "application/xml"]
  def binary?(mime), do: not text?(mime) and not image?(mime)
end
