# Kustomize Components

This directory contains reusable Kustomize components for common Kubernetes infrastructure.

## Active Components

### envoy-gateway
**Status**: ✅ Used by dev overlay  
**Purpose**: Provides Gateway API implementation for ingress

Used in: `Tiltfile` (line 31)

### cnpg-operator
**Status**: ✅ Used by Tiltfile  
**Purpose**: CloudNativePG operator for PostgreSQL cluster management

Used in: `Tiltfile` (lines 6-26) - bootstrapped directly via kubectl

## Available Components (Not Currently Used)

These components are available for use when needed:

### argocd
**Purpose**: ArgoCD GitOps continuous delivery tool  
**Usage**: Deploy with `kubectl apply -k kustomization/components/argocd`  
**When to use**: For production GitOps deployments

### certmanager
**Purpose**: Automatic TLS certificate management  
**Usage**: Add to overlay resources or deploy separately  
**When to use**: When you need automatic HTTPS certificates (Let's Encrypt)

### sealed-secrets-controller
**Purpose**: Encrypt secrets for safe storage in Git  
**Usage**: Deploy with `kubectl apply -k kustomization/components/sealed-secrets-controller`  
**When to use**: For GitOps workflows where secrets need to be stored in Git

## Using Components in Your Overlay

To use a component in your kustomization overlay:

```yaml
# kustomization/overlays/prod/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

components:
  - ../../components/certmanager
  - ../../components/sealed-secrets-controller

resources:
  - ../../bases/server
  # ... other resources
```

## Component Structure

Each component follows the Kustomize component pattern:
- Uses `kind: Component` (not Kustomization)
- Can be included in multiple overlays
- May include external resources (like upstream manifests)
- Often includes ArgoCD sync-wave annotations for proper ordering

## Adding New Components

When adding infrastructure components:
1. Create a new directory with a `kustomization.yaml`
2. Set `kind: Component` (not `Kustomization`)
3. Add resources or reference external manifests
4. Document usage in this README
5. Consider adding ArgoCD sync-wave annotations if order matters
