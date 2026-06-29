# Istio with AKS - Infrastructure

[Back](../README.md)

- [Istio with AKS - Infrastructure](#istio-with-aks---infrastructure)
  - [Terraform](#terraform)
  - [Access AKS via kubectl](#access-aks-via-kubectl)

---

## Terraform

```sh
terraform -chdir=infra init -backend-config=backend.hcl
terraform -chdir=infra fmt && terraform -chdir=infra validate

terraform -chdir=infra apply -auto-approve
terraform -chdir=infra output kubeconfig_command
# az aks get-credentials -g rg-aks-istio-dev -n aks-istio-dev --file ./kubeconfig --overwrite-existing

terraform -chdir=infra destroy -auto-approve

```

---

## Access AKS via kubectl

```sh
az login

SUB_ID=$(az account show --query id --output tsv) && echo $SUB_ID

RG_NAME="rg-aks-istio-dev"
AKS_NAME="aks-istio-dev"

export KUBECONFIG=~/kubeconfig 

az aks get-credentials -g $RG_NAME -n $AKS_NAME --overwrite-existing
kubectl get nodes
# NAME                             STATUS   ROLES    AGE   VERSION
# aks-system-33090782-vmss000000   Ready    <none>   12h   v1.35.5
# aks-system-33090782-vmss000001   Ready    <none>   12h   v1.35.5
```
