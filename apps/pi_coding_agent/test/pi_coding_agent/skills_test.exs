defmodule PiCodingAgent.SkillsTest do
  use ExUnit.Case, async: true
  test "load_all returns list" do
    assert is_list(PiCodingAgent.Skills.load_all())
  end
end
