defmodule PiAi.OAuthTest do
  use ExUnit.Case, async: true
  alias PiAi.OAuth

  test "new creates oauth struct" do
    oauth = OAuth.new("anthropic", client_id: "test")
    assert oauth.provider == "anthropic"
    assert oauth.client_id == "test"
  end

  test "expired? returns false for nil expires_at" do
    oauth = OAuth.new("test")
    refute OAuth.expired?(oauth)
  end

  test "expired? returns true for past date" do
    oauth = %{OAuth.new("test") | expires_at: DateTime.add(DateTime.utc_now(), -3600, :second)}
    assert OAuth.expired?(oauth)
  end

  test "save and load roundtrip" do
    path = "/tmp/oauth_test_#{:rand.uniform(10000)}.json"
    oauth = %{OAuth.new("test") | token: "abc123", refresh_token: "refresh"}
    OAuth.save(oauth, path)
    {:ok, loaded} = OAuth.load(path)
    assert loaded.token == "abc123"
    File.rm!(path)
  end
end

defmodule PiAi.OAuth.PKCETest do
  use ExUnit.Case, async: true
  test "generate creates verifier and challenge" do
    pkce = PiAi.OAuth.PKCE.generate()
    assert is_binary(pkce.code_verifier)
    assert is_binary(pkce.code_challenge)
    assert is_binary(pkce.state)
  end
  test "authorization_url builds correct URL" do
    pkce = PiAi.OAuth.PKCE.generate()
    url = PiAi.OAuth.PKCE.authorization_url(pkce, "https://example.com/auth", "client123", "http://localhost", ["openid"])
    assert url =~ "client_id=client123"
    assert url =~ "code_challenge="
  end
end

defmodule PiAi.OAuth.CredentialsTest do
  use ExUnit.Case, async: true
  test "store and load" do
    dir = "/tmp/creds_test_#{:rand.uniform(10000)}"
    path = Path.join(dir, "test.json")
    File.mkdir_p!(dir)
    PiAi.OAuth.Credentials.store("test_creds", %{token: "abc"})
    {:ok, data} = PiAi.OAuth.Credentials.load("test_creds")
    assert data["token"] == "abc"
    File.rm_rf!(dir)
  end
end
