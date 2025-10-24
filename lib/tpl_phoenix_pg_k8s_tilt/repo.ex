defmodule TplPhoenixPgK8sTilt.Repo do
  use Ecto.Repo,
    otp_app: :tpl_phoenix_pg_k8s_tilt,
    adapter: Ecto.Adapters.Postgres
end
