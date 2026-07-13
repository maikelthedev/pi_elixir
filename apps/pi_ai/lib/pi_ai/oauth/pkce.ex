defmodule PiAi.OAuth.PKCE do
  @moduledoc "PKCE (Proof Key for Code Exchange) OAuth flow implementation."
  defstruct [:code_verifier, :code_challenge, :state]

  def generate do
    verifier = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
    challenge = verifier |> sha256() |> Base.url_encode64(padding: false)
    state = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
    %__MODULE__{code_verifier: verifier, code_challenge: challenge, state: state}
  end

  def authorization_url(pkce, authorize_url, client_id, redirect_uri, scopes) do
    URI.encode_query(
      response_type: "code",
      client_id: client_id,
      redirect_uri: redirect_uri,
      scope: Enum.join(scopes, " "),
      state: pkce.state,
      code_challenge: pkce.code_challenge,
      code_challenge_method: "S256"
    )
    |> then(fn params -> "#{authorize_url}?#{params}" end)
  end

  def exchange_code(pkce, token_url, client_id, redirect_uri, code) do
    body = %{
      grant_type: "authorization_code",
      client_id: client_id,
      code: code,
      redirect_uri: redirect_uri,
      code_verifier: pkce.code_verifier
    }
    HTTPClient.post(token_url, body)
  end

  defp sha256(data), do: :crypto.hash(:sha256, data)
end
