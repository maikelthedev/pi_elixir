defmodule PiCodingAgent.EventBusDeepTest do
  use ExUnit.Case, async: false
  setup do
    start_supervised!({PiCodingAgent.EventBus, name: PiCodingAgent.EventBus})
    :ok
  end
  test "multiple subscribers get events" do
    p1 = self(); p2 = spawn(fn -> :ok end)
    PiCodingAgent.EventBus.subscribe(p1, :test)
    PiCodingAgent.EventBus.subscribe(p2, :test)
    PiCodingAgent.EventBus.emit(:test, %{n: 1})
    assert_receive {:pi_event, %{type: :test}}
  end
  test "history stores events" do
    PiCodingAgent.EventBus.emit(:e1, %{})
    PiCodingAgent.EventBus.emit(:e2, %{})
    h = PiCodingAgent.EventBus.history(5)
    assert length(h) >= 2
  end
  test "subscribe to all events" do
    PiCodingAgent.EventBus.subscribe(self(), :all)
    PiCodingAgent.EventBus.emit(:anything, %{})
    assert_receive {:pi_event, _}
  end
end
