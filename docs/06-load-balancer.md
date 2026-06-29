# Istio with AKS - Load Balaner

[Back](../README.md)

- [Istio with AKS - Load Balaner](#istio-with-aks---load-balaner)
  - [Create and deploy new version app](#create-and-deploy-new-version-app)
  - [Ingress Test](#ingress-test)

---

## Create and deploy new version app

```sh
kubectl apply -f manifests/istio/load-balancer
# destinationrule.networking.istio.io/web created
# virtualservice.networking.istio.io/web configured

kubectl get pods -n default -l app=web
# NAME                      READY   STATUS    RESTARTS   AGE
# web-v1-6455748874-bftbb   2/2     Running   0          4h29m
# web-v1-6455748874-dw2wv   2/2     Running   0          4h29m
# web-v2-68cdf6746d-kh9ng   2/2     Running   0          126m
# web-v2-68cdf6746d-rxtgz   2/2     Running   0          126m

# confirm
INGRESS_IP=$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

kubectl get destinationrule web -n default -o yaml
# apiVersion: networking.istio.io/v1
# kind: DestinationRule
# metadata:
#   annotations:
#     kubectl.kubernetes.io/last-applied-configuration: |
#       {"apiVersion":"networking.istio.io/v1","kind":"DestinationRule","metadata":{"annotations":{},"name":"web","namespace":"default"},"spec":{"host":"web","subsets":[{"labels":{"version":"v1"},"name":"v1"},{"labels":{"version":"v2"},"name":"v2"}]}}
#   creationTimestamp: "2026-06-29T02:50:07Z"
#   generation: 1
#   name: web
#   namespace: default
#   resourceVersion: "195237"
#   uid: 880a7f00-3181-4634-9fb0-3c9298378cb7
# spec:
#   host: web
#   subsets:
#   - labels:
#       version: v1
#     name: v1
#   - labels:
#       version: v2
#     name: v2
```

---

## Ingress Test

```sh
# Test 100 times, count versions; should be ~75/25
for i in $(seq 1 100); do
  curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/
  echo
done | sort | uniq -c
#  79 {"app":"istio app","version":"1.0"}
#  21 {"app":"istio app","version":"2.0"}
```
