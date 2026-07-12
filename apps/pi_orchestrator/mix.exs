defmodule PiOrchestrator.MixProject do
  use Mix.Project

  def project do
    [
      app: :pi_orchestrator,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PiOrchestrator.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:pi_agent, in_umbrella: true},
      {:pi_coding_agent, in_umbrella: true}
    ]
  end
end
