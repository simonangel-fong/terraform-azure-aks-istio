
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

```