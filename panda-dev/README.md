
use the Makefile to pull in updates from the helm

    make helm

this will regenerate the manifests from helm.

we use kustomize to customize the helm deployments for the usdf deployment. you can view the manifests using

    kubectl kustomize .

this uses `kustomization.yaml` file to gather and modify kubernetes manifests. specificaly there are some 'patches' that modify the helm manifests.

you can then also 

    kubectl apply -k .

(or make apply) to push to kubernetes.
