defmodule PiAi.Provider.GoogleVertex do
  @moduledoc "Google Vertex AI (GCP-hosted Gemini models)."
  @behaviour PiAi.Provider

  @impl true
  def stream_chat(model, messages, opts) do
    project_id = System.get_env("VERTEX_PROJECT_ID") || opts[:project_id]
    location = System.get_env("VERTEX_LOCATION") || "us-central1"
    api_key = System.get_env("VERTEX_API_KEY") || ""

    # Vertex uses the same Gemini API with a different endpoint
    api_url = "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/#{model.id}:streamGenerateContent?alt=sse"

    body = PiAi.Provider.Gemini.build_request_body(model, messages, opts)

    request =
      Req.new(
        url: api_url,
        method: :post,
        headers: [
          {"authorization", "Bearer #{api_key}"},
          {"content-type", "application/json"}
        ],
        json: body,
        into: fn chunk, acc -> {:cont, chunk <> (acc || "")} end
      )

    case Req.post(request) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        response = PiAi.EventStream.accumulate([body])
        text = response["content"] || ""
        {:ok, [%{"content" => text}]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Vertex error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def models do
    [
      %PiAi.Model{id: "gemini-2.5-flash-001", name: "Gemini 2.5 Flash (Vertex)", provider: "google-vertex", api: "google-generative-ai", context_window: 1_000_000, max_tokens: 64_000},
      %PiAi.Model{id: "gemini-2.5-pro-001", name: "Gemini 2.5 Pro (Vertex)", provider: "google-vertex", api: "google-generative-ai", context_window: 1_000_000, max_tokens: 64_000}
    ]
  end
end
