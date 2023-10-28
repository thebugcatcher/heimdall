import Config

config :heimdall, Heimdall.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "heimdall_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :heimdall, HeimdallWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "arZhjZ3azvw2rTVcrj3+KdsR0XH0SC5nTA5bye0tZwXG/C1EVwjPfmyCHTEHLoEV",
  server: false

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :heimdall, dev_routes: true

# In order for scheduled prunes to not affect tests
config :heimdall, Heimdall.SecretsPruner, time_interval_ms: 1_000_000
