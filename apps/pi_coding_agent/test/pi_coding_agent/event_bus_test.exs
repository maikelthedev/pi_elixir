defmodule PiCodingAgent.EventBusTest do
  use ExUnit.Case, async: false
  setup do
    start_supervised!({PiCodingAgent.EventBus, name: PiCodingAgent.EventBus})
    :ok
  end
  test "emit and receive events" do
    test_pid = self()
    PiCodingAgent.EventBus.subscribe(test_pid, :test_event)
    PiCodingAgent.EventBus.emit(:test_event, %{data: 42})
    assert_receive {:pi_event, %{type: :test_event, data: %{data: 42}}}
  end
end
