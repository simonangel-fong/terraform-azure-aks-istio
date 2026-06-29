# Istio with AKS - TLS

[Back](../README.md)

- [Istio with AKS - TLS](#istio-with-aks---tls)
  - [Install Cert Manger](#install-cert-manger)
  - [Create Certificate](#create-certificate)
  - [Ingress Ip Test](#ingress-ip-test)

---

## Install Cert Manger

```sh
export KUBECONFIG=~/kubeconfig

helm repo add jetstack https://charts.jetstack.io
helm repo update

helm search repo cert-manager
# NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
# jetstack/cert-manager                   v1.20.3         v1.20.3         A Helm chart for cert-manager

helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true --wait

# enable sidercar injection
kubectl label namespace cert-manager istio-injection=enabled --overwrite
# namespace/cert-manager labeled

kubectl -n cert-manager rollout restart deploy cert-manager cert-manager-cainjector cert-manager-webhook 
# deployment.apps/cert-manager restarted
# deployment.apps/cert-manager-cainjector restarted
# deployment.apps/cert-manager-webhook restarted

kubectl -n cert-manager get pods
# NAME                                       READY   STATUS    RESTARTS   AGE
# cert-manager-7b749d89f8-x8hjs              2/2     Running   0          13s
# cert-manager-cainjector-68dc5546f8-z9vzq   2/2     Running   0          13s
# cert-manager-webhook-6bc6b848b5-h4h75      2/2     Running   0          13s
```

---

## Create Certificate

```sh
# create certificate and cluster issuer
kubectl apply -f manifests/istio/tls
# certificate.cert-manager.io/web-tls created

# confirm
kubectl get certificate -n istio-system
# NAME      READY   SECRET    AGE
# web-tls   True    web-tls   100s

kubectl get clusterissuer
# NAME                READY   AGE
# selfsigned-issuer   True    27s

kubectl -n istio-system get secret web-tls
# NAME      TYPE                DATA   AGE
# web-tls   kubernetes.io/tls   3      7m47s

# update gateway
kubectl apply -f manifests/web-app

```

---

## Ingress Ip Test

```sh
# test
INGRESS_IP=$(kubectl -n istio-ingress get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

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
