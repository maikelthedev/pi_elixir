defmodule PiCodingAgent.AuthGuidance do
  @moduledoc "Provides guidance strings for configuring provider auth."
  def message(provider) do
    case provider do
      "anthropic" -> "Set ANTHROPIC_API_KEY or add to ~/.pi/agent/auth.json"
      "openai" -> "Set OPENAI_API_KEY or add to ~/.pi/agent/auth.json"
      "google" -> "Set GEMINI_API_KEY or add to ~/.pi/agent/auth.json"
      "deepseek" -> "Set DEEPSEEK_API_KEY or add to ~/.pi/agent/auth.json"
      "groq" -> "Set GROQ_API_KEY or add to ~/.pi/agent/auth.json"
      "openrouter" -> "Set OPENROUTER_API_KEY or add to ~/.pi/agent/auth.json"
      _ -> "Set #{String.upcase(provider)}_API_KEY or add to ~/.pi/agent/auth.json"
    end
  end
end
