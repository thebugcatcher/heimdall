defmodule Heimdall.Factory do
  @moduledoc false

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
end
