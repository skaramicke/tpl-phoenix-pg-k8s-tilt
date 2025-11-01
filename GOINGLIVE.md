# Going Live - Production Deployment Guide

This guide will help you deploy your Phoenix application to production using Kubernetes and ArgoCD.

## Prerequisites

- A Kubernetes cluster (GKE, EKS, AKS, or self-managed)
- kubectl configured to access your cluster
- ArgoCD installed on your cluster
- A GitHub App or Personal Access Token for ArgoCD to access your repository
- Container registry access (GHCR, Docker Hub, ECR, etc.)

## Step 1: Prepare Your Secrets

Production secrets should be managed securely using Sealed Secrets or your cloud provider's secret management service.

### Option A: Using Sealed Secrets (Recommended for GitOps)

1. Install the sealed-secrets controller:
   ```bash
   kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.32.2/controller.yaml
   ```

2. Install the kubeseal CLI:
   ```bash
   brew install kubeseal  # macOS
   # Or download from: https://github.com/bitnami-labs/sealed-secrets/releases
   ```

3. Create and encrypt your production secrets:
   ```bash
   # Generate a strong secret key base
   mix phx.gen.secret
   
   # Generate a strong release cookie
   mix phx.gen.secret
   
   # Create your secrets and seal them
   kubectl create secret generic distribution-secret \
     --from-literal=release_cookie=YOUR_RELEASE_COOKIE \
     --from-literal=secret_key_base=YOUR_SECRET_KEY_BASE \
     --dry-run=client -o yaml | \
   kubeseal --controller-namespace kube-system -o yaml > kustomization/bases/secrets/sealed-secrets.yaml
   ```

### Option B: Using Cloud Provider Secret Management

Refer to your cloud provider's documentation:
- **AWS**: AWS Secrets Manager + External Secrets Operator
- **GCP**: Google Secret Manager + External Secrets Operator
- **Azure**: Azure Key Vault + External Secrets Operator

## Step 2: Build and Push Production Container Image

1. Update the image reference in `kustomization/bases/server/server-cluster-set.yaml` to your registry:
   ```yaml
   image: your-registry.io/your-org/tpl-phoenix-pg-k8s-tilt:v1.0.0
   ```

2. Build and push the production image:
   ```bash
   docker build -f Dockerfile -t your-registry.io/your-org/tpl-phoenix-pg-k8s-tilt:v1.0.0 .
   docker push your-registry.io/your-org/tpl-phoenix-pg-k8s-tilt:v1.0.0
   ```

## Step 3: Deploy Infrastructure Components

Deploy the necessary operators and controllers:

```bash
# Deploy CNPG operator (for PostgreSQL)
kubectl apply -k kustomization/components/cnpg-operator

# Deploy Envoy Gateway (for ingress)
kubectl apply -k kustomization/components/envoy-gateway

# Wait for operators to be ready
kubectl wait --for=condition=available --timeout=300s \
  deployment/cnpg-controller-manager -n cnpg-system
kubectl wait --for=condition=available --timeout=300s \
  deployment/envoy-gateway -n envoy-gateway-system
```

## Step 4: Deploy via ArgoCD

1. Create a GitHub App for ArgoCD (if not already done):
   - Go to GitHub Settings > Developer Settings > GitHub Apps
   - Create a new GitHub App with repository read access
   - Generate and download the private key

2. Update the ArgoCD repository configuration in `kustomization/argocd/repo.yaml`

3. Deploy the ArgoCD application:
   ```bash
   kubectl apply -k kustomization/argocd
   ```

4. ArgoCD will automatically sync and deploy your application

## Step 5: Configure DNS and TLS

1. Update the Gateway hostname in `kustomization/bases/server/gateway.yaml` to your production domain

2. Add TLS certificate configuration (using cert-manager):
   ```yaml
   listeners:
     - name: https
       protocol: HTTPS
       port: 443
       hostname: your-domain.com
       tls:
         certificateRefs:
           - name: your-tls-cert
   ```

3. Ensure your DNS points to the Envoy Gateway load balancer:
   ```bash
   kubectl get svc -n envoy-gateway-system
   ```

## Step 6: Run Database Migrations

After the application pods are running:

```bash
kubectl exec -it server-set-0 -n tpl-phoenix-pg-k8s-tilt -- bin/tpl_phoenix_pg_k8s_tilt eval "TplPhoenixPgK8sTilt.Release.migrate()"
```

Or add migrations to your release startup process.

## Step 7: Verify Deployment

1. Check pod status:
   ```bash
   kubectl get pods -n tpl-phoenix-pg-k8s-tilt
   ```

2. Check logs:
   ```bash
   kubectl logs -f server-set-0 -n tpl-phoenix-pg-k8s-tilt
   ```

3. Test the application:
   ```bash
   curl https://your-domain.com
   ```

## Monitoring and Observability

Consider adding:
- Prometheus for metrics collection
- Grafana for visualization
- Loki for log aggregation
- Sentry for error tracking

## Scaling

The StatefulSet is configured for 3 replicas by default. Adjust in `kustomization/bases/server/server-cluster-set.yaml`:

```yaml
spec:
  replicas: 5  # Adjust as needed
```

## Backup and Disaster Recovery

The PostgreSQL cluster managed by CNPG supports:
- Continuous archiving with WAL shipping
- Point-in-time recovery (PITR)
- Automated backups to S3-compatible storage

Configure backup in `kustomization/bases/database/pg-cluster.yaml`.

## Additional Resources

- [Phoenix Deployment Guides](https://hexdocs.pm/phoenix/deployment.html)
- [CloudNativePG Documentation](https://cloudnative-pg.io/)
- [Envoy Gateway Documentation](https://gateway.envoyproxy.io/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
