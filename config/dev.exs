import Config

config :heimdall, Heimdall.Repo,
  username: System.get_env("HEIMDALL_DB_USERNAME") || "postgres",
  password: System.get_env("HEIMDALL_DB_PASSWORD") || "postgres",
  database: System.get_env("HEIMDALL_DB_NAME") || "heimdall_dev",
  hostname: System.get_env("HEIMDALL_DB_HOST") || "localhost",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :heimdall, HeimdallWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "sZkCBKihsT/PA+xSnFgEDtXe4bFkQgoSGMa02eCszB0MXfYyfvOwHYG82EpG2CFS",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :heimdall, HeimdallWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/heimdall_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :heimdall, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
