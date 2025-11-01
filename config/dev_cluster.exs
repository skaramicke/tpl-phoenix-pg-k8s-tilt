import Config

# Endpoint with live reload + code reloader like dev
config :tpl_phoenix_pg_k8s_tilt, TplPhoenixPgK8sTiltWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")],
  server: true,
  check_origin: false,
  code_reloader: true,
  debug_errors: false,
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "dev_cluster_only_secret",
  watchers: [
    esbuild:
      {Esbuild, :install_and_run, [:tpl_phoenix_pg_k8s_tilt, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:tpl_phoenix_pg_k8s_tilt, ~w(--watch)]}
  ],
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/tpl_phoenix_pg_k8s_tilt_web/(?:controllers|live|components|router)/?.*\.(ex|heex)$"
    ]
  ]

# Dev conveniences
config :tpl_phoenix_pg_k8s_tilt, dev_routes: true
config :logger, :default_formatter, format: "[$level] $message\n"
config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true

# Use Local mailer like dev
config :tpl_phoenix_pg_k8s_tilt, TplPhoenixPgK8sTilt.Mailer, adapter: Swoosh.Adapters.Local
config :swoosh, :api_client, false
