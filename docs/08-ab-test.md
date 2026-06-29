# Istio with AKS - A/B Test

[Back](../README.md)

- [Istio with AKS - A/B Test](#istio-with-aks---ab-test)
  - [Deploy Applications](#deploy-applications)
  - [A/B Test Rollout](#ab-test-rollout)
  - [Test](#test)

---

## Deploy Applications

```sh
# Apply manifests
kubectl apply -f manifests/web-app

kubectl get pods -n default -l app=web
# NAME                      READY   STATUS    RESTARTS   AGE
# web-v1-6455748874-8x4r8   2/2     Running   0          2m55s
# web-v1-6455748874-v5h7v   2/2     Running   0          2m55s
# web-v2-68cdf6746d-kh9ng   2/2     Running   0          3h22m
# web-v2-68cdf6746d-rxtgz   2/2     Running   0          3h22m
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
INGRESS_IP=$(kubectl -n istio-ingress get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

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
