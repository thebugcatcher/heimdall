defmodule Heimdall.Factory do
  @moduledoc false

  alias Heimdall.Secrets

  alias Timex.Duration

  def valid_secret_params(params \\ %{}) do
    Map.merge(
      %{
        title: "Title",
        encrypted_text: "Text",
        encryption_algo: :aes_gcm,
        encryption_key: "Password",
        expires_at: Timex.add(DateTime.utc_now(), Duration.from_minutes(5))
      },
      params
    )
  end

  def encrypt_and_create(params \\ %{}) do
    params
    |> valid_secret_params
    |> Secrets.encrypt_and_create()
  end

  def valid_secret_attempt_params(params \\ %{}) do
    Map.merge(
      %{
        secret_id: Ecto.UUID.generate(),
        ip_address: "10.0.0.1",
        attempted_at: DateTime.add(DateTime.utc_now(), -10, :second)
      },
      params
    )
  end

  def valid_secret_read_params(params \\ %{}) do
    Map.merge(
      %{
        secret_id: Ecto.UUID.generate(),
        ip_address: "10.0.0.1",
        read_at: DateTime.add(DateTime.utc_now(), -10, :second)
      },
      params
    )
  end
end
