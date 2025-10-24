import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :tpl_phoenix_pg_k8s_tilt, TplPhoenixPgK8sTilt.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "tpl_phoenix_pg_k8s_tilt_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tpl_phoenix_pg_k8s_tilt, TplPhoenixPgK8sTiltWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "JTSb7xWuH9Yq4WIdYlCLqmoldS+WimsfzxxeVdd+CuJXKL8AESaRsrMHAVr37rDd",
  server: false

# In test we don't send emails
config :tpl_phoenix_pg_k8s_tilt, TplPhoenixPgK8sTilt.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
