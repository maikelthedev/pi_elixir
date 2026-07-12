defmodule PiAi.ModelRegistryTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_registry_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end

  describe "load/1" do
    test "creates registry file if missing and returns models", %{dir: dir} do
      path = Path.join(dir, "models.json")
      models = PiAi.ModelRegistry.load(path)
      assert is_list(models)
      assert length(models) > 0
      assert File.exists?(path)
    end

    test "loads from existing file", %{dir: dir} do
      path = Path.join(dir, "models.json")

      # First call creates it
      _first = PiAi.ModelRegistry.load(path)
      assert File.exists?(path)

      # Second call reads it
      _second = PiAi.ModelRegistry.load(path)
      assert File.exists?(path)
    end
  end

  describe "search/2" do
    test "finds models by partial name", %{dir: dir} do
      path = Path.join(dir, "models.json")
      PiAi.ModelRegistry.load(path)

      results = PiAi.ModelRegistry.search("gpt", path)
      assert length(results) > 0
      assert Enum.all?(results, &(String.contains?(String.downcase(&1.id), "gpt") or String.contains?(String.downcase(&1.name || ""), "gpt")))
    end
  end
end
