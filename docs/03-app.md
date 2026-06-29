# Istio with AKS - Simple API App

[Back](../README.md)

- [Istio with AKS - Simple API App](#istio-with-aks---simple-api-app)
  - [Create API Application with nginx](#create-api-application-with-nginx)

---

## Create API Application with nginx

```sh
# Apply manifests
kubectl apply -f manifests/web-app

# confirm: ready 2/2
kubectl get deploy web-v1 -n default

# Each pod shows 2/2 containers (nginx + istio-proxy sidecar)
kubectl get pods -n default -l app=web

# Test from inside the cluster (sidecar in the curl pod too)
kubectl run curl --rm -it --image=curlimages/curl --restart=Never -- sh -c 'curl -s http://web/ ; echo ; curl -s http://web/healthz ; echo'
# {"app":"istio app","version":"1.0"}
# ok

```

---

```sh
# create gateway.yaml
kubectl apply -f istio/istio-gateway/gateway.yaml
# gateway.networking.istio.io/web-gateway created

kubectl apply -f istio/istio-gateway/virtualservice.yaml
# virtualservice.networking.istio.io/web created

kubectl get gateway
# NAME          AGE
# web-gateway   24s

kubectl get vs
# Warning: short name "vs" could also match lower priority resource volumesnapshots.snapshot.storage.k8s.io
# NAME   GATEWAYS          HOSTS   AGE
# web    ["web-gateway"]   ["*"]   18s

INGRESS_IP=$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "ingress IP: $INGRESS_IP"

# test
curl -s http://$INGRESS_IP/        ; echo
# {"app":"istio app","version":"1.0"}
curl -s http://$INGRESS_IP/healthz ; echo
# ok
```
