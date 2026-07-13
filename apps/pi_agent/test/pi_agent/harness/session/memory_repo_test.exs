defmodule PiAgent.Harness.Session.MemoryRepoTest do
  use ExUnit.Case, async: false
  setup do
    start_supervised!({PiAgent.Harness.Session.MemoryRepo, name: PiAgent.Harness.Session.MemoryRepo})
    :ok
  end
  test "save and load roundtrip" do
    PiAgent.Harness.Session.MemoryRepo.save("s1", [%{data: "hello"}])
    assert PiAgent.Harness.Session.MemoryRepo.load("s1") == [%{data: "hello"}]
  end
  test "list returns keys" do
    PiAgent.Harness.Session.MemoryRepo.save("a", [])
    PiAgent.Harness.Session.MemoryRepo.save("b", [])
    assert "a" in PiAgent.Harness.Session.MemoryRepo.list()
  end
end
