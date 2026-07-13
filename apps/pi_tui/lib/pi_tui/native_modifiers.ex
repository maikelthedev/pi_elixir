defmodule PiTui.NativeModifiers do
  @moduledoc "Handles platform-specific modifier key mappings."

  @doc "Returns whether the platform uses Cmd (macOS) or Ctrl (others) for primary shortcuts."
  def meta_key do
    case :os.type() do
      {:unix, :darwin} -> :cmd
      _ -> :ctrl
    end
  end

  @doc "Returns key mappings adjusted for the current platform."
  def platform_bindings(base \\ PiTui.Keybindings.default_bindings()) do
    case meta_key() do
      :cmd ->
        base
        |> Map.put({:cmd, ?c}, :copy)
        |> Map.put({:cmd, ?v}, :paste)
        |> Map.put({:cmd, ?x}, :cut)
        |> Map.put({:cmd, ?z}, :undo)
        |> Map.put({:cmd, ?s}, :save)
      _ ->
        base
    end
  end
end
