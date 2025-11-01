# Phoenix + PostgreSQL + Kubernetes + Tilt Template

A production-ready template for Elixir Phoenix applications with:
- **Kubernetes deployment** using Kustomize
- **Local development** with Tilt for hot reloading
- **Distributed Elixir** cluster with libcluster
- **PostgreSQL** managed by CloudNativePG operator
- **Ingress** via Envoy Gateway
- **GitOps ready** with ArgoCD support

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) (Kubernetes in Docker)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Tilt](https://docs.tilt.dev/install.html)
- Make

### Development Setup

1. **Clone this template** and initialize your project:
   ```bash
   git clone https://github.com/skaramicke/tpl-phoenix-pg-k8s-tilt.git my-app
   cd my-app
   ```

2. **Start the development environment**:
   ```bash
   make tilt
   ```

   This command will:
   - Create a local kind cluster with 3 worker nodes
   - Install CloudNativePG operator
   - Install Envoy Gateway
   - Deploy a 3-instance PostgreSQL cluster
   - Deploy a 3-node Phoenix application cluster
   - Enable hot reloading for code changes

3. **Access your application**:
   - Open [http://server.localtest.me:8080](http://server.localtest.me:8080)
   - The Tilt UI is available at [http://localhost:10350](http://localhost:10350)

### What You Get

The `make tilt` command sets up a fully working distributed Phoenix application with:

- **3 Phoenix nodes** forming an Elixir cluster (using libcluster with Kubernetes DNS strategy)
- **3 PostgreSQL instances** in high-availability configuration (managed by CloudNativePG)
- **Hot reloading** - code changes are synced and recompiled automatically
- **Live view** - asset changes trigger browser refresh
- **Port forwarding** - automatic access via local domains

### Development Workflow

1. **Make code changes** - Tilt automatically syncs and recompiles
2. **View logs** - Use the Tilt UI or `kubectl logs`
3. **Test clustering** - Connect to nodes via `kubectl exec`
4. **Database access** - Connect directly to PostgreSQL via port-forward

### Customizing for Your Project

After cloning, you'll want to:

1. **Rename the application**:
   - Update `mix.exs` app name
   - Update module names throughout the project
   - Update image names in `Tiltfile` and `kustomization/bases/server/server-cluster-set.yaml`
   - Update namespace in `kustomization/namespace/namespace.yaml`

2. **Configure secrets**:
   - Update `kustomization/overlays/dev/secrets/*.env` for development
   - For production, use Sealed Secrets or your cloud provider's secret manager (see [GOINGLIVE.md](./GOINGLIVE.md))

3. **Adjust resources**:
   - Modify replica counts in `kustomization/bases/server/server-cluster-set.yaml`
   - Adjust resource limits based on your needs
   - Update database storage size in `kustomization/bases/database/pg-cluster.yaml`

## Project Structure

```
.
├── lib/                          # Phoenix application code
├── config/                       # Application configuration
│   ├── dev_cluster.exs          # Config for dev cluster (hot reload + distributed)
│   └── runtime.exs              # Runtime config (prod + dev_cluster)
├── kustomization/               # Kubernetes manifests
│   ├── bases/                   # Base resources
│   │   ├── server/             # Phoenix StatefulSet, Service, Gateway, Routes
│   │   ├── database/           # PostgreSQL Cluster
│   │   └── secrets/            # Secret templates
│   ├── overlays/               # Environment-specific configs
│   │   ├── dev/               # Development overlay (used by Tilt)
│   │   └── prod/              # Production overlay
│   ├── components/             # Reusable components
│   │   ├── envoy-gateway/     # Envoy Gateway installation
│   │   ├── cnpg-operator/     # CloudNativePG operator
│   │   ├── argocd/            # ArgoCD installation
│   │   ├── certmanager/       # Cert-manager (for TLS)
│   │   └── sealed-secrets-controller/  # Sealed Secrets
│   ├── argocd/                # ArgoCD Application definitions
│   └── namespace/             # Namespace definition
├── Dockerfile                  # Production container image
├── Dockerfile.dev             # Development container image
├── Tiltfile                   # Tilt configuration
├── Makefile                   # Common commands
└── GOINGLIVE.md              # Production deployment guide
```

## Available Commands

```bash
make help              # Show all available commands
make tilt              # Start development environment
make clean             # Delete the kind cluster
make kind              # Create kind cluster only
make kubectl-context   # Switch kubectl context to kind cluster
```

## Features in Detail

### Distributed Elixir Cluster

The application automatically forms an Elixir cluster using libcluster with the Kubernetes DNS strategy. All 3 nodes can communicate via distributed Erlang.

Test clustering:
```bash
kubectl exec -it server-set-0 -n tpl-phoenix-pg-k8s-tilt -- bin/tpl_phoenix_pg_k8s_tilt remote
> Node.list()
[:"server@10.244.1.5", :"server@10.244.2.4"]
```

### High-Availability PostgreSQL

CloudNativePG manages a 3-instance PostgreSQL cluster with:
- Automatic failover
- Streaming replication
- Point-in-time recovery support
- Backup capabilities

### Hot Reloading

The development setup uses:
- `MIX_ENV=dev_cluster` for hot reloading
- Tilt's `live_update` to sync code changes
- Phoenix LiveReload for asset updates

### Ingress with Envoy Gateway

Envoy Gateway provides:
- Gateway API support (modern Kubernetes ingress)
- HTTP routing
- TLS termination (in production)
- Load balancing across pods

## Production Deployment

See [GOINGLIVE.md](./GOINGLIVE.md) for comprehensive production deployment instructions including:
- Secret management with Sealed Secrets
- Container image building and registry
- DNS and TLS configuration
- Database migrations
- Monitoring and observability
- Scaling and backup strategies

## Troubleshooting

### Tilt fails to start

```bash
# Clean up and restart
make clean
make tilt
```

### Can't access the application

```bash
# Check port forwarding
kubectl get svc -n envoy-gateway-system

# Check pod status
kubectl get pods -n tpl-phoenix-pg-k8s-tilt

# View logs
kubectl logs -f server-set-0 -n tpl-phoenix-pg-k8s-tilt
```

### Database connection issues

```bash
# Check PostgreSQL cluster status
kubectl get cluster -n tpl-phoenix-pg-k8s-tilt

# Check database pods
kubectl get pods -l cnpg.io/cluster=database-cluster -n tpl-phoenix-pg-k8s-tilt
```

## Learn More

### Phoenix Framework
* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix

### Kubernetes & Cloud Native
* [CloudNativePG](https://cloudnative-pg.io/) - PostgreSQL operator
* [Envoy Gateway](https://gateway.envoyproxy.io/) - Gateway API implementation
* [Tilt](https://tilt.dev/) - Local Kubernetes development
* [Kustomize](https://kustomize.io/) - Kubernetes configuration management
* [ArgoCD](https://argo-cd.readthedocs.io/) - GitOps continuous delivery

### Elixir Clustering
* [libcluster](https://hexdocs.pm/libcluster/readme.html) - Cluster formation
* [Distributed Erlang](https://www.erlang.org/doc/reference_manual/distributed.html)

## Contributing

This is a template repository. Feel free to fork and customize for your needs!

## License

This template is available as open source under the terms of the MIT License.
