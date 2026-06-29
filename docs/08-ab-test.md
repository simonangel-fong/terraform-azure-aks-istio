# Istio with AKS - A/B Test

[Back](../README.md)

- [Istio with AKS - A/B Test](#istio-with-aks---ab-test)
  - [Deploy Applications](#deploy-applications)

---

## Deploy Applications

```sh
# Apply manifests
kubectl apply -f manifests/web-app

kubectl get pods -n default -l app=web
```
