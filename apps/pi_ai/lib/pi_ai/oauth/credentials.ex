defmodule PiAi.OAuth.Credentials do
  @moduledoc "Manages OAuth credentials storage and loading."
  @credentials_dir Path.expand("~/.pi/credentials")

  def store(provider, token_data) do
    path = credential_path(provider)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, JSON.encode!(token_data))
  end

  def load(provider) do
    case File.read(credential_path(provider)) do
      {:ok, content} -> JSON.decode(content)
      {:error, :enoent} -> {:error, :not_found}
      error -> error
    end
  end

  def delete(provider) do
    File.rm(credential_path(provider))
  end

  def list do
    case File.ls(@credentials_dir) do
      {:ok, files} -> Enum.filter(files, &String.ends_with?(&1, ".json")) |> Enum.map(&String.trim_trailing(&1, ".json"))
      {:error, _} -> []
    end
  end

  defp credential_path(provider), do: Path.join(@credentials_dir, "#{provider}.json")
end
