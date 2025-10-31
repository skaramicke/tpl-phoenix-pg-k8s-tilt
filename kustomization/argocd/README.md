# ArgoCD Application

## Deploying the application, step by step

1. Create a GitHub application for ArgoCD repo access:  
    Open the prefilled GitHub App creation form by [clicking here](https://github.com/settings/apps/new?name=tpl-phoenix-pg-k8s-tilt&url=https://tpl-phoenix-pg-k8s-tilt.com&description=Used+by+ArgoCD+to+find+new+versions+of+the+tpl-phoenix-pg-k8s-tilt+application&public=false&contents=read&metadata=read&webhook_active=false) and click `Create GitHub App`
2. Scroll down to [the bottom](https://github.com/settings/apps/tpl-phoenix-pg-k8s-tilt#private-key) and click `Generate a private key`

To apply this application to your cluster, run the following from the project root

1. `mix k8s.gen.sealed_secret`
2. `kustomize build kustomization/argocd | kubectl apply -f -`
