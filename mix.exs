defmodule Confload.Mixfile do
  use Mix.Project

  def project do
    [
      app: :confload,
      version: "0.2.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Confload, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:file_system, "~> 0.1.5", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "OTP compliant configuration reloader for distillery"
  end

  defp package do
    [maintainers: ["Dmitry A. Russ"],
     licenses: ["Apache 2.0"],
     links: %{"Github" => "https://github.com/liveforeverx/confload"}]
  end
end
