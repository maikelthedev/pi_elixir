defmodule PiCodingAgent.MigrationsTest do
  use ExUnit.Case, async: true
  test "run returns ok or noop" do
    result = PiCodingAgent.Migrations.run()
    assert result == :ok or result == :noop
  end
end
