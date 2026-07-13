defmodule PiCodingAgent.ComponentsDeepTest do
  use ExUnit.Case, async: true

  test "all 40 components can be compiled" do
    components = [
      PiCodingAgent.Component.Armin,
      PiCodingAgent.Component.AssistantMessage,
      PiCodingAgent.Component.BashExecution,
      PiCodingAgent.Component.BorderedLoader,
      PiCodingAgent.Component.BranchSummaryMessage,
      PiCodingAgent.Component.CompactionSummary,
      PiCodingAgent.Component.ConfigSelector,
      PiCodingAgent.Component.CountdownTimer,
      PiCodingAgent.Component.CustomEditor,
      PiCodingAgent.Component.CustomMessage,
      PiCodingAgent.Component.Daxnuts,
      PiCodingAgent.Component.Diff,
      PiCodingAgent.Component.DynamicBorder,
      PiCodingAgent.Component.EarendilAnnouncement,
      PiCodingAgent.Component.ExtensionEditor,
      PiCodingAgent.Component.ExtensionInput,
      PiCodingAgent.Component.ExtensionSelector,
      PiCodingAgent.Component.FirstTimeSetup,
      PiCodingAgent.Component.Footer,
      PiCodingAgent.Component.KeybindingHints,
      PiCodingAgent.Component.LoginDialog,
      PiCodingAgent.Component.ModelSelector,
      PiCodingAgent.Component.OAuthSelector,
      PiCodingAgent.Component.ScopedModelsSelector,
      PiCodingAgent.Component.SessionSelector,
      PiCodingAgent.Component.SessionSelectorSearch,
      PiCodingAgent.Component.SettingsSelector,
      PiCodingAgent.Component.ShowImagesSelector,
      PiCodingAgent.Component.SkillInvocation,
      PiCodingAgent.Component.StatusIndicator,
      PiCodingAgent.Component.ThemeSelector,
      PiCodingAgent.Component.ThinkingSelector,
      PiCodingAgent.Component.ToolExecution,
      PiCodingAgent.Component.TreeSelector,
      PiCodingAgent.Component.TrustSelector,
      PiCodingAgent.Component.UserMessage,
      PiCodingAgent.Component.UserMessageSelector,
      PiCodingAgent.Component.VisualTruncate
    ]
    Enum.each(components, fn comp ->
      assert is_atom(comp), "Component #{inspect(comp)} should be a module"
      fns = comp.__info__(:functions) |> Enum.map(&elem(&1, 0))
      assert length(fns) > 0, "#{inspect(comp)} should have at least one public function"
    end)
  end
end
