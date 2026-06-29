

```sh
# Apply manifests
KUBECONFIG=./kubeconfig kubectl apply -f web-app/

# Wait for rollout
KUBECONFIG=./kubeconfig kubectl -n default rollout status deploy/web-v1

# Deployment ready 2/2
KUBECONFIG=./kubeconfig kubectl get deploy web-v1 -n default

# Each pod shows 2/2 containers (nginx + istio-proxy sidecar)
KUBECONFIG=./kubeconfig kubectl get pods -n default -l app=web

# Test from inside the cluster (sidecar in the curl pod too)
KUBECONFIG=./kubeconfig kubectl run curl --rm -it --image=curlimages/curl --restart=Never -- sh -c 'curl -s http://web/ ; echo ; curl -s http://web/healthz ; echo'
# {"app":"istio app","version":"1.0"}
# ok

```

---

```sh
# create gateway.yaml
KUBECONFIG=./kubeconfig kubectl apply -f istio/istio-gateway/gateway.yaml
# gateway.networking.istio.io/web-gateway created

KUBECONFIG=./kubeconfig kubectl apply -f istio/istio-gateway/virtualservice.yaml
# virtualservice.networking.istio.io/web created

KUBECONFIG=./kubeconfig kubectl get gateway
# NAME          AGE
# web-gateway   24s

KUBECONFIG=./kubeconfig kubectl get vs
# Warning: short name "vs" could also match lower priority resource volumesnapshots.snapshot.storage.k8s.io
# NAME   GATEWAYS          HOSTS   AGE
# web    ["web-gateway"]   ["*"]   18s

INGRESS_IP=$(KUBECONFIG=./kubeconfig kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "ingress IP: $INGRESS_IP"

# test
curl -s http://$INGRESS_IP/        ; echo
# {"app":"istio app","version":"1.0"}
curl -s http://$INGRESS_IP/healthz ; echo
# ok
```