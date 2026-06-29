# Istio with AKS - Simple API App

[Back](../README.md)

- [Istio with AKS - Simple API App](#istio-with-aks---simple-api-app)
  - [Create API Application with nginx](#create-api-application-with-nginx)
  - [Incluster Test](#incluster-test)
  - [Ingress Test](#ingress-test)

---

## Create API Application with nginx

```sh
export KUBECONFIG=~/kubeconfig

# enable sidercar injection
kubectl label namespace default istio-injection=enabled --overwrite

# Apply manifests
kubectl apply -f manifests/web-app

# confirm: ready 2/2
kubectl get deploy web-v1 -n default
# NAME     READY   UP-TO-DATE   AVAILABLE   AGE
# web-v1   2/2     2            2           3h57m

kubectl get pods -n default -l app=web
# NAME                      READY   STATUS    RESTARTS   AGE
# web-v1-6455748874-bftbb   2/2     Running   0          3h57m
# web-v1-6455748874-dw2wv   2/2     Running   0          3h57m

kubectl get gateway
# NAME          AGE
# web-gateway   24s

kubectl get virtualservice
# NAME   GATEWAYS          HOSTS           AGE
# web    ["web-gateway"]   ["web.local"]   18s
```

---

## Incluster Test

```sh
kubectl run curl --rm -it --image=curlimages/curl --restart=Never -- sh -c 'curl -s http://web/ ; echo ; curl -s http://web/healthz ; echo'
# {"app":"istio app","version":"1.0"}
# ok
# pod "curl" deleted from default namespace
```

---

## Ingress Test

```sh
INGRESS_IP=$(kubectl -n istio-ingress get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "ingress IP: $INGRESS_IP"
# ingress IP: 20.121.180.84

# test: http; no tls
curl -s http://$INGRESS_IP/; echo
# {"app":"istio app","version":"1.0"}
curl -s http://$INGRESS_IP/healthz; echo
# ok
```
