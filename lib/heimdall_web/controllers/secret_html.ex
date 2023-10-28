defmodule HeimdallWeb.SecretHTML do
  use HeimdallWeb, :html

  alias Heimdall.Data.Secret

  alias Timex.Duration

  embed_templates "secret_html/*"

  def expiration_options do
    datetime = DateTime.utc_now()

    [
      {"5 min", Timex.add(datetime, Duration.from_minutes(5))},
      {"15 min", Timex.add(datetime, Duration.from_minutes(15))},
      {"30 min", Timex.add(datetime, Duration.from_minutes(30))},
      {"1 hour", Timex.add(datetime, Duration.from_hours(1))},
      {"2 hours", Timex.add(datetime, Duration.from_hours(2))}
    ]
  end
end
