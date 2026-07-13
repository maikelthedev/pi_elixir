defmodule PiOrchestrator.StorageTest do
  use ExUnit.Case, async: true
  test "save and load" do
    PiOrchestrator.Storage.save_session("test_inst", %{key: "val"})
    assert {:ok, %{"key" => "val"}} = PiOrchestrator.Storage.load_session("test_inst")
    PiOrchestrator.Storage.delete_session("test_inst")
  end
end
