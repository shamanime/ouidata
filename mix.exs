defmodule Ouidata.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ouidata,
      name: "ouidata",
      version: "0.1.0",
      elixir: "~> 1.8",
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:hackney, :logger],
      env: env(),
      mod: {Ouidata.App, []}
    ]
  end

  defp deps do
    [
      {:hackney, "~> 1.0"},
      {:ex_doc, "~> 0.20", only: :dev}
    ]
  end

  defp env do
    [autoupdate: :enabled, data_dir: nil]
  end

  defp description do
    """
    Ouidata is a parser and library for the Wireshark OUI database.
    """
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Jefferson Venerando"],
      links: %{"GitHub" => "https://github.com/shamanime/ouidata"},
      files: ~w(lib priv mix.exs README* LICENSE*
                 CHANGELOG*)
    }
  end
end
