defmodule PiAi.OAuth do
  @moduledoc "OAuth 2.0 support for AI providers: device code, PKCE, token management."
  require Logger

  defstruct [:provider, :client_id, :redirect_uri, :scopes, :token, :refresh_token, :expires_at]

  @type t :: %__MODULE__{
    provider: String.t(), client_id: String.t(), redirect_uri: String.t(),
    scopes: [String.t()], token: String.t() | nil, refresh_token: String.t() | nil,
    expires_at: DateTime.t() | nil
  }

  def new(provider, opts \\ []) do
    %__MODULE__{
      provider: provider,
      client_id: Keyword.get(opts, :client_id, ""),
      redirect_uri: Keyword.get(opts, :redirect_uri, "http://localhost:3000/callback"),
      scopes: Keyword.get(opts, :scopes, [])
    }
  end

  def device_code_authorize(oauth, device_code_url) do
    body = %{
      client_id: oauth.client_id,
      scope: Enum.join(oauth.scopes, " ")
    }
    case HTTPClient.post(device_code_url, body) do
      {:ok, resp} -> {:ok, Map.put(oauth, :device_code, resp["device_code"])}
      error -> error
    end
  end

  def poll_for_token(oauth, token_url, interval \\ 5) do
    Process.sleep(interval * 1000)
    body = %{
      client_id: oauth.client_id,
      device_code: oauth.device_code,
      grant_type: "urn:ietf:params:oauth:grant-type:device_code"
    }
    case HTTPClient.post(token_url, body) do
      {:ok, %{"access_token" => token} = resp} ->
        {:ok, %{oauth | token: token, refresh_token: resp["refresh_token"],
                expires_at: expiration_from(resp)}}
      {:ok, %{"error" => "authorization_pending"}} -> {:pending, oauth}
      {:ok, %{"error" => "slow_down"}} -> {:slow_down, oauth}
      {:ok, %{"error" => err}} -> {:error, err}
      error -> error
    end
  end

  def refresh(oauth, token_url) do
    case oauth.refresh_token do
      nil -> {:error, :no_refresh_token}
      refresh_token ->
        body = %{
          client_id: oauth.client_id,
          refresh_token: refresh_token,
          grant_type: "refresh_token"
        }
        case HTTPClient.post(token_url, body) do
          {:ok, resp} ->
            {:ok, %{oauth | token: resp["access_token"],
                    refresh_token: resp["refresh_token"] || refresh_token,
                    expires_at: expiration_from(resp)}}
          error -> error
        end
    end
  end

  def expired?(%__MODULE__{expires_at: nil}), do: false
  def expired?(%__MODULE__{expires_at: expires_at}), do: DateTime.compare(DateTime.utc_now(), expires_at) == :gt

  def save(oauth, path) do
    data = %{provider: oauth.provider, token: oauth.token, refresh_token: oauth.refresh_token,
             expires_at: oauth.expires_at && DateTime.to_iso8601(oauth.expires_at)}
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, JSON.encode!(data))
  end

  def load(path) do
    case File.read(path) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, data} ->
            {:ok, %__MODULE__{
              provider: data["provider"],
              token: data["token"],
              refresh_token: data["refresh_token"],
              expires_at: data["expires_at"] && DateTime.from_iso8601!(data["expires_at"])
            }}
          error -> error
        end
      error -> error
    end
  end

  defp expiration_from(%{"expires_in" => expires_in}) do
    DateTime.add(DateTime.utc_now(), expires_in, :second)
  end
  defp expiration_from(_), do: nil
end
