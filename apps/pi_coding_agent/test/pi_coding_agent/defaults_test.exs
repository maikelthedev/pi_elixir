defmodule PiCodingAgent.DefaultsTest do
  use ExUnit.Case, async: true
  test "get returns default" do
    assert PiCodingAgent.Defaults.get(:model) == "anthropic/claude-sonnet-4-20250514"
  end
  test "get with custom default" do
    assert PiCodingAgent.Defaults.get(:nonexistent, "fallback") == "fallback"
  end
  test "all returns map" do
    assert is_map(PiCodingAgent.Defaults.all())
  end
  test "for_env(:test)" do
    defaults = PiCodingAgent.Defaults.for_env(:test)
    assert defaults.model == "faux/test"
  end
end

defmodule PiCodingAgent.ExecTest do
  use ExUnit.Case, async: true
  test "run captures output" do
    result = PiCodingAgent.Exec.run("echo hello")
    assert result.stdout =~ "hello"
    assert result.exit_code == 0
    assert result.timed_out == false
  end
  test "run with error exit code" do
    result = PiCodingAgent.Exec.run("exit 1")
    assert result.exit_code == 1
  end
end

defmodule PiCodingAgent.MessagesTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  alias PiCodingAgent.Messages

  test "format_single converts message" do
    msg = %Message{role: :user, content: "hi"}
    result = Messages.format_single(msg)
    assert result["role"] == "user"
    assert result["content"] == "hi"
  end

  test "count_tokens_single estimates" do
    msg = %Message{role: :user, content: String.duplicate("x", 400)}
    assert Messages.count_tokens_single(msg) >= 100
  end

  test "compact reduces messages" do
    msgs = for i <- 1..50, do: %Message{role: :user, content: "msg #{i}"}
    compacted = Messages.compact(msgs, 200)
    assert length(compacted) < 50
  end

  test "last_assistant finds last assistant message" do
    msgs = [%Message{role: :user, content: "a"}, %Message{role: :assistant, content: "b"}]
    assert %Message{content: "b"} = Messages.last_assistant(msgs)
  end
end

defmodule PiCodingAgent.ModelResolverTest do
  use ExUnit.Case, async: true
  test "resolve full path" do
    assert {:ok, "anthropic/claude-sonnet-4-20250514"} = PiCodingAgent.ModelResolver.resolve("anthropic/claude-sonnet-4-20250514")
  end
  test "resolve alias" do
    assert {:ok, "anthropic/claude-sonnet-4-20250514"} = PiCodingAgent.ModelResolver.resolve("sonnet")
  end
  test "resolve unknown returns error" do
    assert {:error, :not_found} = PiCodingAgent.ModelResolver.resolve("zzz_nonexistent_zzz")
  end
end

defmodule PiCodingAgent.TimingsTest do
  use ExUnit.Case, async: true
  test "start and stop timer" do
    t = PiCodingAgent.Timings.new()
    |> PiCodingAgent.Timings.start_timer(:test)
    Process.sleep(10)
    t = PiCodingAgent.Timings.stop_timer(t, :test)
    assert PiCodingAgent.Timings.elapsed_ms(t, :test) >= 10
  end
  test "record metric" do
    t = PiCodingAgent.Timings.new() |> PiCodingAgent.Timings.record(:test, 42)
    assert PiCodingAgent.Timings.elapsed_ms(t, :test) == 42
  end
  test "summary returns map" do
    t = PiCodingAgent.Timings.new() |> PiCodingAgent.Timings.record(:a, 10) |> PiCodingAgent.Timings.record(:a, 20)
    s = PiCodingAgent.Timings.summary(t)
    assert s[:a].count == 2
  end
end

defmodule PiCodingAgent.TrustManagerTest do
  use ExUnit.Case, async: true
  setup do
    dir = "/tmp/trust_test_#{:rand.uniform(10000)}"
    File.mkdir_p!(dir)
    start_supervised!({PiCodingAgent.TrustManager, project_dir: dir, name: :test_trust})
    on_exit(fn -> File.rm_rf!(dir) end)
    :ok
  end
  test "starts untrusted" do
    assert :untrusted = PiCodingAgent.TrustManager.trust_level(:test_trust)
  end
  test "set_trust changes level" do
    :ok = PiCodingAgent.TrustManager.set_trust(:test_trust, :trusted)
    assert :trusted = PiCodingAgent.TrustManager.trust_level(:test_trust)
  end
  test "can_execute?" do
    refute PiCodingAgent.TrustManager.can_execute?(:test_trust, "bash")
    PiCodingAgent.TrustManager.set_trust(:test_trust, :trusted)
    assert PiCodingAgent.TrustManager.can_execute?(:test_trust, "bash")
  end
end
