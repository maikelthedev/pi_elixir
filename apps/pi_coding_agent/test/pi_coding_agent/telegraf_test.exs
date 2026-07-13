defmodule PiCodingAgent.TelegrafTest do
  use ExUnit.Case, async: true
  test "report returns ok without eventbus" do
    assert PiCodingAgent.Telegraf.report() == :ok
  end
end
