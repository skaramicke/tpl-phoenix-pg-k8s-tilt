# CNPG Operator bootstrap
# This local_resource ensures that the CloudNativePG operator is installed
# and ready before any other resources that depend on it are applied.
# 
# CNPG operator is responsible for managing PostgreSQL clusters in Kubernetes.
local_resource(
  'cnpg-bootstrap',
  '''
  set -euo pipefail
  kubectl apply --server-side --force-conflicts \
    --field-manager=tilt-cnpg-bootstrap \
    -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.1.yaml

  kubectl -n cnpg-system wait deploy/cnpg-controller-manager \
    --for=condition=Available --timeout=180s

  for i in $(seq 1 90); do
    cb="$(kubectl get mutatingwebhookconfiguration cnpg-mutating-webhook-configuration \
      -o jsonpath='{.webhooks[0].clientConfig.caBundle}' 2>/dev/null || true)"
    [ -n "$cb" ] && { echo "CNPG webhook CA injected."; exit 0; }
    echo "Waiting for CNPG webhook CA injection..."; sleep 2
  done
  echo "CNPG webhook CA not injected in time" >&2; exit 1
  ''',
  allow_parallel=False,
)

# Install Envoy Gateway
# This applies the Envoy Gateway manifests from the kustomize component.
# Envoy Gateway is used as the ingress controller for the application.
k8s_yaml(kustomize("kustomization/components/envoy-gateway"))

# Apply the development overlay
# This includes all the necessary resources for the development environment.
# It depends on the CNPG bootstrap to ensure the database operator is ready.
k8s_yaml(kustomize("kustomization/overlays/dev"))

# Define resource dependencies
# Ensure that the Envoy Gateway and server cluster are applied
# only after the CNPG operator is bootstrapped.
k8s_resource('envoy-gateway', resource_deps=['cnpg-bootstrap'])
k8s_resource('server-set', resource_deps=['cnpg-bootstrap'])

# Port forwarding to the envoy gateway of the server-cluster
local_resource(
  'pf-public-gw',
  serve_cmd='''
  set -eu
  svc="$(kubectl -n envoy-gateway-system get svc \
    -l gateway.envoyproxy.io/owning-gateway-name=public-gw \
    -o jsonpath='{.items[0].metadata.name}')"
  echo "Port-forwarding $svc:80 -> 8080"
  exec kubectl -n envoy-gateway-system port-forward svc/$svc 8080:80
  ''',
  allow_parallel=True,
  deps=["envoy-gateway", "server-cluster"],
)

# Docker build configuration
# This builds the development Docker image for the server application
# with live updates for faster development iterations.
docker_build(
    "ghcr.io/skaramicke/tpl-phoneix-pg-k8s-tilt/server:latest",
    ".",
    dockerfile="Dockerfile.dev",
    only=[
      "mix.exs",
      "mix.lock",
      "config",
      "lib",
      "assets",
      "priv",
      "Dockerfile.dev",
    ],
    live_update=[
        # sync sources
        sync("lib", "/app/lib/"),
        sync("config", "/app/config/"),
        sync("priv", "/app/priv/"),
        sync("assets", "/app/assets/"),
        sync("mix.exs", "/app/mix.exs"),
        sync("mix.lock", "/app/mix.lock"),

        # deps when mix files change
        run("mix deps.get && mix deps.compile", trigger=["mix.exs", "mix.lock"]),

        # fast compile on code edits
        run("mix compile --return-errors", trigger=["lib/**", "config/**"]),
    ],
)
