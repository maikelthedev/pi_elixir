defmodule PiElixir.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        pi: [
          applications: [
            pi_orchestrator: :permanent,
            pi_coding_agent: :permanent,
            pi_agent: :permanent,
            pi_ai: :permanent,
            pi_tui: :permanent
          ],
          steps: [:assemble, :tar]
        ]
      ]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.37", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false}
    ]
  end
end
