defmodule PiAi.Images do
  @moduledoc """
  Image generation support for providers that support it.
  """

  @doc "Generates an image using the given provider and prompt."
  @spec generate(String.t(), String.t(), keyword()) :: {:ok, String.t()} | {:error, String.t()}
  def generate(provider, prompt, opts \\ []) do
    case provider do
      "openrouter" ->
        generate_openrouter(prompt, opts)
      _ ->
        {:error, "Image generation not supported for provider: #{provider}"}
    end
  end

  defp generate_openrouter(prompt, opts) do
    api_key = System.get_env("OPENROUTER_API_KEY") || ""

    case Req.post("https://openrouter.ai/api/v1/images/generations",
      json: %{
        model: Keyword.get(opts, :model, "dall-e-3"),
        prompt: prompt,
        n: Keyword.get(opts, :n, 1),
        size: Keyword.get(opts, :size, "1024x1024")
      },
      headers: [{"authorization", "Bearer #{api_key}"}]
    ) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        url = body["data"] |> List.first() |> Map.get("url")
        {:ok, url}

      {:ok, %Req.Response{status: status}} ->
        {:error, "Image generation failed: HTTP #{status}"}

      {:error, reason} ->
        {:error, "Image generation failed: #{inspect(reason)}"}
    end
  end
end
