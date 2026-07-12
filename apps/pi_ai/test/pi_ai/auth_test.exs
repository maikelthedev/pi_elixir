defmodule PiAi.AuthTest do
  use ExUnit.Case, async: true

  setup do
    tmp_dir = Path.join(System.tmp_dir!(), "pi_auth_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf!(tmp_dir) end)
    %{dir: tmp_dir}
  end

  describe "load/1" do
    test "returns nil for missing provider", %{dir: dir} do
      assert PiAi.Auth.load("anthropic", dir) == {:ok, nil}
    end

    test "reads a key from the auth file", %{dir: dir} do
      auth_path = Path.join(dir, "auth.json")
      File.write!(auth_path, JSON.encode!(%{"anthropic" => %{"api_key" => "sk-ant-123"}}))

      assert {:ok, %{"api_key" => "sk-ant-123"}} = PiAi.Auth.load("anthropic", dir)
    end

    test "returns error for corrupted JSON", %{dir: dir} do
      auth_path = Path.join(dir, "auth.json")
      File.write!(auth_path, "not json")

      assert {:error, _} = PiAi.Auth.load("anthropic", dir)
    end
  end

  describe "save/3" do
    test "writes a key and reads it back", %{dir: dir} do
      assert :ok = PiAi.Auth.save("openai", %{"api_key" => "sk-abc"}, dir)
      assert {:ok, %{"api_key" => "sk-abc"}} = PiAi.Auth.load("openai", dir)
    end

    test "merges with existing providers", %{dir: dir} do
      PiAi.Auth.save("anthropic", %{"api_key" => "sk-ant-1"}, dir)
      PiAi.Auth.save("openai", %{"api_key" => "sk-abc"}, dir)

      assert {:ok, %{"api_key" => "sk-ant-1"}} = PiAi.Auth.load("anthropic", dir)
      assert {:ok, %{"api_key" => "sk-abc"}} = PiAi.Auth.load("openai", dir)
    end
  end
end
