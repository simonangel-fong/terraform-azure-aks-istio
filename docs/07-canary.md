# Istio with AKS - Canary

[Back](../README.md)

- [Istio with AKS - Canary](#istio-with-aks---canary)
  - [Create Ingress Request](#create-ingress-request)
  - [Stable version](#stable-version)
  - [Canary Version](#canary-version)
    - [Step 1: 80 / 20](#step-1-80--20)
    - [Step 2: 50 / 50](#step-2-50--50)
    - [Step 3: 0 / 100](#step-3-0--100)
  - [Decommission v1](#decommission-v1)

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

## Stable version

```sh
# deploy dr
kubectl apply -f manifests/istio/canary/stable-dr.yaml
# destinationrule.networking.istio.io/web configured
kubectl apply -f manifests/istio/canary/stable-vs.yaml
# virtualservice.networking.istio.io/web configured

# Test: reqeust 100x; tally versions
sample() {
  for i in $(seq 1 100); do
    curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/
    echo
  done | sort | uniq -c
}

sample
# 100 {"app":"istio app","version":"1.0"}
```

---

## Canary Version

### Step 1: 80 / 20

```sh
kubectl apply -f manifests/istio/canary/canary-dr.yaml
# destinationrule.networking.istio.io/web configured
kubectl apply -f manifests/istio/canary/canary-vs01.yaml
# virtualservice.networking.istio.io/web configured

sample
#  76 {"app":"istio app","version":"1.0"}
#  24 {"app":"istio app","version":"2.0"}
```

### Step 2: 50 / 50

```sh
kubectl apply -f manifests/istio/canary/canary-vs02.yaml
# virtualservice.networking.istio.io/web configured

sample
#  49 {"app":"istio app","version":"1.0"}
#  51 {"app":"istio app","version":"2.0"}
```

### Step 3: 0 / 100

```sh
kubectl apply -f manifests/istio/canary/canary-vs03.yaml
# virtualservice.networking.istio.io/web configured

sample
# 100 {"app":"istio app","version":"2.0"}
```

---

## Decommission v1 

```sh
kubectl delete deploy web-v1 -n default
kubectl delete configmap web-v1-nginx -n default

kubectl edit destinationrule web -n default 
```