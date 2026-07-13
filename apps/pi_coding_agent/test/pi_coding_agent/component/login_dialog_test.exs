defmodule PiCodingAgent.Component.LoginDialogTest do
  use ExUnit.Case, async: true
  test "renders waiting state" do
    result = PiCodingAgent.Component.LoginDialog.render("openai", :waiting)
    assert Enum.join(result) =~ "openai"
  end
  test "renders success state" do
    result = PiCodingAgent.Component.LoginDialog.render("openai", :success)
    assert Enum.join(result) =~ "saved"
  end
end
