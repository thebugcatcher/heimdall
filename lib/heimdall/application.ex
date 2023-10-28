defmodule Heimdall.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      Enum.reject(
        [
          HeimdallWeb.Telemetry,
          Heimdall.Repo,
          maybe_start_pruner(),
          {Phoenix.PubSub, name: Heimdall.PubSub},
          {Finch, name: Heimdall.Finch},
          HeimdallWeb.Endpoint
        ],
        &is_nil/1
      )

    opts = [strategy: :one_for_one, name: Heimdall.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    HeimdallWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp maybe_start_pruner do
    if pruner_enabled?() do
      Heimdall.SecretsPruner
    end
  end

  defp pruner_enabled? do
    Application.get_env(:heimdall, Heimdall.SecretsPruner)[:enabled]
  end
end
