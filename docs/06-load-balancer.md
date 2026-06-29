```sh
export KUBECONFIG=~/kubeconfig

kubectl apply -f manifests/web-app/

kubectl get pods -n default -l app=web
# NAME                      READY   STATUS    RESTARTS   AGE
# web-v1-6455748874-bftbb   2/2     Running   0          145m
# web-v1-6455748874-dw2wv   2/2     Running   0          145m
# web-v2-68cdf6746d-kh9ng   2/2     Running   0          2m54s
# web-v2-68cdf6746d-rxtgz   2/2     Running   0          2m54s

# confirm
INGRESS_IP=$(kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

kubectl get destinationrule web -n default -o yaml | grep -A1 subsets

# Hit it 100 times, count versions — should be ~75/25
for i in $(seq 1 100); do
  curl -ks --resolve web.local:443:$INGRESS_IP https://web.local/
  echo
done | sort | uniq -c
#  79 {"app":"istio app","version":"1.0"}
#  21 {"app":"istio app","version":"2.0"}
```
