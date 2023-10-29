import Config

if System.get_env("PHX_SERVER", "true") do
  config :heimdall, HeimdallWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 =
    if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :heimdall, Heimdall.Repo,
    ssl: true,
    ssl_opts: [verify: :verify_none],
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env(
      "SECRET_KEY_BASE",
      "Vbo6JHmYRO2tNqQGtlAKO2qa4aQIP+ABixTgUFhn5gsB9qgpHuTI6epRT+KKnDCJ"
    )

  host = System.get_env("PHX_HOST", "")
  port = String.to_integer(System.get_env("PORT", "4000"))

  config :heimdall, HeimdallWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    force_ssl: [rewrite_on: [:x_forwarded_proto]],
    secret_key_base: secret_key_base
end

if config_env() != :test do
  config :heimdall, Heimdall.SecretsPruner,
    enabled: System.get_env("PRUNE_OLD_SECRETS", "true") == "true",
    time_interval_ms:
      String.to_integer(System.get_env("SECRETS_PRUNER_INTERVAL_MS", "30000")),
    delete_query_timeout:
      String.to_integer(System.get_env("DELETE_QUERY_TIMEOUT_MS", "1500"))

  config :heimdall,
    secret_expiration_check_period_ms:
      String.to_integer(
        System.get_env("SECRET_EXPIRATION_CHECK_PERIOD_MS", "5000")
      )

  config :heimdall,
    admin_user: System.get_env("ADMIN_USER", "admin"),
    admin_password: System.get_env("ADMIN_PASSWORD", "admin")
end
