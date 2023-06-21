# rubin-iam-db
## Deployment framework for Rubin USDF IAM. 

## Bare minimum installation

This installation flavour provides the minimum resources required to run `mariadb-operator` in your cluster.

```bash
helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
helm install -n iam-db mariadb-operator mariadb-operator/mariadb-operator

# when mariadb-operator fails to be delete, run these commands
kubectl delete clusterrole mariadb-manager-role
kubectl delete ClusterRoleBinding mariadb-manager-rolebinding
kubectl delete ValidatingWebhookConfiguration mariadb-operator-webhook
```

 helm install --dry-run -n test iam-db-test helm/mariadb/ -f helm/mariadb/values.yaml  -f helm/mariadb/values/values-lsst.yaml 

## install the mariadb

```bash
cd rubin-iam-db-deploy/overlays/dev
make apply
```
