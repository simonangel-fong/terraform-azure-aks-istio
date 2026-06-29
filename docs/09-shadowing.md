# Istio with AKS - Shadow Deployment

[Back](../README.md)

- [Istio with AKS - Shadow Deployment](#istio-with-aks---shadow-deployment)
  - [Deploy Applications](#deploy-applications)
  - [Create Ingress Request](#create-ingress-request)
  - [Test](#test)

---

## Deploy Applications

```sh
export KUBECONFIG=~/kubeconfig

kubectl apply -f manifests/web-app/

# Apply the mirror VirtualService
kubectl apply -f manifests/istio/mirror/mirror-vs.yaml
```

---

## Create Ingress Request

```sh
export KUBECONFIG=~/kubeconfig

INGRESS_IP=$(kubectl -n istio-ingress get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

while true; do
  curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/ >/dev/null
  sleep 0.2
done
```

---

## Test

```sh
INGRESS_IP=$(kubectl -n istio-ingress get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# v1: mirror is invisible
for i in $(seq 1 100); do
  curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/
  echo
done | sort | uniq -c

# confirm mirror by v2 log
kubectl logs -n default -l app=web,version=v2 -c nginx -f --tail=0=0
# 127.0.0.6 - - [29/Jun/2026:18:21:24 +0000] "GET / HTTP/1.1" 200 35 "-" "curl/8.5.0" "10.10.0.4,10.10.0.34"
# 127.0.0.6 - - [29/Jun/2026:18:21:25 +0000] "GET / HTTP/1.1" 200 35 "-" "curl/8.5.0" "10.10.0.4,10.10.0.34"
# 127.0.0.6 - - [29/Jun/2026:18:21:25 +0000] "GET / HTTP/1.1" 200 35 "-" "curl/8.5.0" "10.10.0.4,10.10.0.34"
# 127.0.0.6 - - [29/Jun/2026:18:21:25 +0000] "GET / HTTP/1.1" 200 35 "-" "curl/8.5.0" "10.10.0.4,10.10.0.34"
# 127.0.0.6 - - [29/Jun/2026:18:21:26 +0000] "GET / HTTP/1.1" 200 35 "-" "curl/8.5.0" "10.10.0.4,10.10.0.34"
# 127.0.0.6 - - [29/Jun/2026:18:21:26 +0000] "GET / HTTP/1.1" 200 35 "-" "curl/8.5.0" "10.10.0.4,10.10.0.34"

```
