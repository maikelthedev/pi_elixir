defmodule PiCodingAgent.Component.ExtensionEditorTest do
  use ExUnit.Case, async: true
  test "renders code lines" do
    result = PiCodingAgent.Component.ExtensionEditor.render(["def foo, do: :ok"], 0, 0, 15)
    assert Enum.join(result) =~ "def foo"
  end
end
