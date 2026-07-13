defmodule PiAi.OAuth.DeviceCode do
  @moduledoc "OAuth 2.0 Device Authorization Grant flow."
  alias PiAi.OAuth

  def start(oauth, device_authorization_url) do
    case OAuth.device_code_authorize(oauth, device_authorization_url) do
      {:ok, oauth} ->
        verification_uri = oauth.verification_uri || "https://anthropic.com/activate"
        IO.puts("Please visit: #{verification_uri}")
        code_display = oauth.device_code || "check your browser"
        IO.puts("Enter code: #{code_display}")
        poll_loop(oauth)
      error -> error
    end
  end

  defp poll_loop(oauth, attempts \\ 0) do
    if attempts > 60 do
      {:error, :timeout}
    else
      case OAuth.poll_for_token(oauth, token_url(oauth.provider)) do
        {:ok, oauth} -> {:ok, oauth}
        {:pending, oauth} -> poll_loop(oauth, attempts + 1)
        {:slow_down, oauth} ->
          Process.sleep(5000)
          poll_loop(oauth, attempts + 1)
        {:error, reason} -> {:error, reason}
      end
    end
  end

  defp token_url("anthropic"), do: "https://console.anthropic.com/api/auth/token"
  defp token_url("github-copilot"), do: "https://github.com/login/oauth/access_token"
  defp token_url(_), do: "https://oauth2.googleapis.com/token"
end
