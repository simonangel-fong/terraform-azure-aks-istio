# Istio with AKS - Canary

[Back](../README.md)

- [Istio with AKS - Canary](#istio-with-aks---canary)
  - [Create Ingress Request](#create-ingress-request)
  - [Stable version](#stable-version)
  - [Canary](#canary)
    - [Step 1: 80 / 20](#step-1-80--20)

---

## Create Ingress Request

```sh
export KUBECONFIG=~/kubeconfig

INGRESS_IP=$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

while true; do
  curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/ >/dev/null
  sleep 0.2
done
```

---

## Stable version

```sh
# deploy dr
kubectll apply -f manifests/istio/canary/dr-stable.yaml

kubectll apply -f manifests/istio/canary/vs-stable.yaml

# Test hit the app 100x and tally versions
sample() {
  for i in $(seq 1 100); do
    curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/
    echo
  done | sort | uniq -c
}


```

---

## Canary

### Step 1: 80 / 20

```sh
kubectl apply -f manifests/canary/step1-80-20.yaml
# virtualservice.networking.istio.io/web configured

```
