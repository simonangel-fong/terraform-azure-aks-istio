```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm search repo cert-manager
# NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
# jetstack/cert-manager                   v1.20.3         v1.20.3         A Helm chart for cert-manager

KUBECONFIG=./kubeconfig helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true --wait

KUBECONFIG=./kubeconfig kubectl -n cert-manager get pods
# NAME                                       READY   STATUS    RESTARTS   AGE
# cert-manager-559776c68d-c8jqk              1/1     Running   0          47s
# cert-manager-cainjector-7cdf9b4bd8-2rlwp   1/1     Running   0          47s
# cert-manager-webhook-5f7fd7899-lzvnk       1/1     Running   0          47s

# create certificate
KUBECONFIG=./kubeconfig kubectl apply -f istio/tls/certificate.yaml
# certificate.cert-manager.io/web-tls created

# create issuer
KUBECONFIG=./kubeconfig kubectl apply -f istio/tls/clusterissuer.yaml
# clusterissuer.cert-manager.io/selfsigned-issuer created


# confirm
KUBECONFIG=./kubeconfig kubectl get certificate -n istio-system
# NAME      READY   SECRET    AGE
# web-tls   True    web-tls   100s

KUBECONFIG=./kubeconfig kubectl get clusterissuer
# NAME                READY   AGE
# selfsigned-issuer   True    27s

KUBECONFIG=./kubeconfig kubectl -n istio-system get secret web-tls
# NAME      TYPE                DATA   AGE
# web-tls   kubernetes.io/tls   3      7m47s

# update gateway
KUBECONFIG=./kubeconfig kubectl apply -f istio/gateway/gateway.yaml
# gateway.networking.istio.io/web-gateway configured

KUBECONFIG=./kubeconfig kubectl apply -f istio/gateway/virtualservice.yaml
# virtualservice.networking.istio.io/web configured

# confirm
KUBECONFIG=./kubeconfig kubectl get gateway
# NAME          AGE
# web-gateway   119s
KUBECONFIG=./kubeconfig kubectl get virtualservice
# NAME   GATEWAYS          HOSTS           AGE
# web    ["web-gateway"]   ["web.local"]   73s

```

```sh
# test
INGRESS_IP=$(KUBECONFIG=./kubeconfig kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -I --resolve web.local:80:$INGRESS_IP http://web.local/
# HTTP/1.1 301 Moved Permanently
# location: https://web.local/
# date: Mon, 29 Jun 2026 01:31:13 GMT
# server: istio-envoy
# transfer-encoding: chunked

curl -k --resolve web.local:443:$INGRESS_IP https://web.local/; echo
# {"app":"istio app","version":"1.0"}
curl -k --resolve web.local:443:$INGRESS_IP https://web.local/healthz; echo
# ok

# Inspect the served cert
openssl s_client -connect $INGRESS_IP:443 -servername web.local </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer -dates
# subject=CN = web.local
# issuer=CN = web.local
# notBefore=Jun 29 01:22:09 2026 GMT
# notAfter=Sep 27 01:22:09 2026 GMT
```
