## Stable version

```sh
export KUBECONFIG=~/kubeconfig

INGRESS_IP=$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test hit the app 100x and tally versions
sample() {
  for i in $(seq 1 100); do
    curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/
    echo
  done | sort | uniq -c
}

while true; do
  curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/ >/dev/null
  sleep 0.2
done
```

---

## Canary

### Step 1: 80 / 20

```sh
kubectl apply -f manifests/canary/step1-80-20.yaml
# virtualservice.networking.istio.io/web configured

```