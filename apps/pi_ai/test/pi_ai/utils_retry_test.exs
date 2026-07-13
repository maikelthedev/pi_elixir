defmodule PiAi.Utils.RetryTest do
  use ExUnit.Case, async: true

  test "retry succeeds on first try" do
    assert {:ok, 42} = PiAi.Utils.Retry.retry(fn -> {:ok, 42} end)
  end

  test "retry succeeds after failures" do
    {:ok, counter} = Agent.start_link(fn -> 0 end)
    result = PiAi.Utils.Retry.retry(fn ->
      Agent.update(counter, &(&1 + 1))
      count = Agent.get(counter, & &1)
      if count < 3, do: {:error, :timeout}, else: {:ok, :done}
    end, max_retries: 5, base_delay: 1)
    assert {:ok, :done} = result
    Agent.stop(counter)
  end

  test "retry fails after max retries" do
    result = PiAi.Utils.Retry.retry(fn -> {:error, :permanent} end, max_retries: 2, base_delay: 1)
    assert {:error, :permanent} = result
  end
end

defmodule PiAi.Utils.DiagnosticsTest do
  use ExUnit.Case, async: true

  test "timing returns result and duration" do
    {result, elapsed} = PiAi.Utils.Diagnostics.timing(fn -> 42 end)
    assert result == 42
    assert elapsed >= 0
  end

  test "collect_stats returns map" do
    stats = PiAi.Utils.Diagnostics.collect_stats()
    assert is_map(stats)
    assert Map.has_key?(stats, :memory)
  end
end

defmodule PiCodingAgent.Utils.AnsiTest do
  use ExUnit.Case, async: true

  test "strip removes ANSI codes" do
    assert PiCodingAgent.Utils.Ansi.strip("\e[31mred\e[0m") == "red"
  end

  test "color adds codes" do
    result = PiCodingAgent.Utils.Ansi.color("hello", :red)
    assert result =~ "\e[31m"
    assert result =~ "hello"
  end

  test "bold adds codes" do
    assert PiCodingAgent.Utils.Ansi.bold("text") =~ "\e[1m"
  end

  test "visible_length ignores ANSI" do
    text = "\e[31mhello\e[0m"
    assert PiCodingAgent.Utils.Ansi.visible_length(text) == 5
  end
end

defmodule PiCodingAgent.Utils.GitTest do
  use ExUnit.Case, async: true

  test "git_dir? returns boolean" do
    assert is_boolean(PiCodingAgent.Utils.Git.git_dir?("/home/maikel/code/pi_elixir"))
  end

  test "root_dir returns ok for git repo" do
    assert {:ok, _} = PiCodingAgent.Utils.Git.root_dir("/home/maikel/code/pi_elixir")
  end

  test "branch returns ok for git repo" do
    assert {:ok, _} = PiCodingAgent.Utils.Git.branch("/home/maikel/code/pi_elixir")
  end
end
