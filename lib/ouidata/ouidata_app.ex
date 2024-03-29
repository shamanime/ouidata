defmodule Ouidata.App do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Ouidata.EtsHolder, [])
    ]

    children =
      case Application.fetch_env(:ouidata, :autoupdate) do
        {:ok, :enabled} -> children ++ [worker(Ouidata.ReleaseUpdater, [])]
        {:ok, :disabled} -> children
      end

    {:ok, _} = Supervisor.start_link(children, strategy: :one_for_one)
  end
end
