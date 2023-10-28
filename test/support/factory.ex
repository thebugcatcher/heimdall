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
end
