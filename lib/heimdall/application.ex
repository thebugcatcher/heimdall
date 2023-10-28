defmodule Heimdall.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HeimdallWeb.Telemetry,
      Heimdall.Repo,
      {Phoenix.PubSub, name: Heimdall.PubSub},
      {Finch, name: Heimdall.Finch},
      HeimdallWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Heimdall.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    HeimdallWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end