# Istio with AKS - Shadow Deployment

[Back](../README.md)

- [Istio with AKS - Shadow Deployment](#istio-with-aks---shadow-deployment)
  - [Deploy Applications](#deploy-applications)
  - [A/B Test Rollout](#ab-test-rollout)
  - [Test](#test)

---

## Deploy Applications

```sh
export KUBECONFIG=~/kubeconfig

kubectl apply -f manifests/web-app/

# Apply the mirror VirtualService
kubectl apply -f manifests/istio/mirror/mirror-vs.yaml
istioctl analyze -n default

```

---

## A/B Test Rollout

```sh
# rollout
kubectl apply -f manifests/istio/ab-test/ab-vs.yaml
# virtualservice.networking.istio.io/web configured

istioctl analyze -n default
```

---

## Test

```sh
INGRESS_IP=$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# ##############################
# Rule 1: valid header hit v2.0
# ##############################
# valid header
curl -ks -H "x-test: true" --resolve web.local:443:$INGRESS_IP https://web.local/; echo
# {"app":"istio app","version":"2.0"}

# invalid header
curl -ks -H "x-test: nope" --resolve web.local:443:$INGRESS_IP https://web.local/; echo
# {"app":"istio app","version":"1.0"}

# valid header: 100 × v2, zero v1
for i in $(seq 1 100); do
  curl -ks -H "x-test: true" --resolve web.local:443:$INGRESS_IP https://web.local/
  echo
done | sort | uniq -c
# 100 {"app":"istio app","version":"2.0"}

# ##############################
# Rule 2: Default split 90:10
# ##############################
# Default traffic: ~90 v1 / ~10 v2
for i in $(seq 1 100); do
  curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/
  echo
done | sort | uniq -c
#  89 {"app":"istio app","version":"1.0"}
#  11 {"app":"istio app","version":"2.0"}
```
