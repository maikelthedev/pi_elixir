defmodule PiCodingAgent.OAuth do
  @moduledoc """
  OAuth 2.0 authentication for LLM providers.

  Supports device code flow for CLI-based auth and
  authorization code flow for web-based auth.
  """

  @device_code_timeout 300_000

  @doc """
  Performs device code flow OAuth.

  Returns {:ok, credentials} or {:error, reason}.
  """
  @spec device_code(String.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, String.t()}
  def device_code(client_id, scope, token_url, opts \\ []) do
    device_url = Keyword.get(opts, :device_url, token_url |> String.replace("token", "device/code"))

    # Step 1: Request device code
    case Req.post(device_url, json: %{client_id: client_id, scope: scope}) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        device_code = body["device_code"]
        user_code = body["user_code"]
        verification_uri = body["verification_uri"] || body["verification_url"]
        interval = (body["interval"] || 5) * 1000
        expires_in = body["expires_in"] || @device_code_timeout

        # Show user code
        IO.puts(:stderr, "\n#{PiTui.Terminal.styled(" OAuth Login ", :reverse)}")
        IO.puts(:stderr, "  Visit: #{PiTui.Terminal.styled(verification_uri, :underline)}")
        IO.puts(:stderr, "  Enter code: #{PiTui.Terminal.styled(user_code, :bold, :green)}")
        IO.puts(:stderr, "")

        # Step 2: Poll for token
        poll_token(token_url, device_code, interval, expires_in)

      {:ok, %Req.Response{status: status}} ->
        {:error, "Device code request failed with status #{status}"}

      {:error, reason} ->
        {:error, "Device code request failed: #{inspect(reason)}"}
    end
  end

  defp poll_token(url, device_code, interval, expires_in, elapsed \\ 0) do
    if elapsed >= expires_in do
      {:error, "Device code expired"}
    else
      Process.sleep(min(interval, 5000))

      case Req.post(url, json: %{
        grant_type: "urn:ietf:params:oauth:grant-type:device_code",
        device_code: device_code
      }) do
        {:ok, %Req.Response{status: 200, body: body}} ->
          {:ok, %{
            access_token: body["access_token"],
            refresh_token: body["refresh_token"],
            expires_in: body["expires_in"],
            token_type: body["token_type"] || "Bearer"
          }}

        {:ok, %Req.Response{body: %{"error" => "authorization_pending"}}} ->
          poll_token(url, device_code, interval, expires_in, elapsed + interval)

        {:ok, %Req.Response{body: %{"error" => "slow_down"}}} ->
          poll_token(url, device_code, interval + 5000, expires_in, elapsed + interval)

        {:ok, %Req.Response{body: %{"error" => error}}} ->
          {:error, "OAuth error: #{error}"}

        {:error, reason} ->
          {:error, "Polling failed: #{inspect(reason)}"}
      end
    end
  end

  @doc "Stores OAuth credentials for a provider."
  def store_credentials(provider, credentials) do
    PiCodingAgent.Settings.set("oauth_#{provider}", credentials)
  end

  @doc "Retrieves stored OAuth credentials for a provider."
  def get_credentials(provider) do
    PiCodingAgent.Settings.get("oauth_#{provider}")
  end

  @doc "Refreshes an expired token if a refresh token is available."
  def refresh_token(provider, refresh_url) do
    case get_credentials(provider) do
      %{"refresh_token" => refresh} ->
        case Req.post(refresh_url, json: %{
          grant_type: "refresh_token",
          refresh_token: refresh
        }) do
          {:ok, %Req.Response{status: 200, body: body}} ->
            new_creds = %{
              access_token: body["access_token"],
              refresh_token: body["refresh_token"] || refresh,
              expires_in: body["expires_in"],
              token_type: body["token_type"] || "Bearer"
            }
            store_credentials(provider, new_creds)
            {:ok, new_creds}

          {:ok, %Req.Response{status: status}} ->
            {:error, "Token refresh failed with status #{status}"}

          {:error, reason} ->
            {:error, "Token refresh failed: #{inspect(reason)}"}
        end

      _ ->
        {:error, "No refresh token available"}
    end
  end
end
