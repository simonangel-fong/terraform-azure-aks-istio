# Istio with AKS - Monitoring

[Back](../README.md)

- [Istio with AKS - Monitoring](#istio-with-aks---monitoring)
  - [Install Istio addons](#install-istio-addons)
  - [Create Gateway](#create-gateway)

---

## Install Istio addons

```sh
ISTIO_VER=1.30

for addon in prometheus grafana jaeger kiali; do
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_VER}/samples/addons/${addon}.yaml
done
# serviceaccount/prometheus created
# configmap/prometheus created
# clusterrole.rbac.authorization.k8s.io/prometheus created
# clusterrolebinding.rbac.authorization.k8s.io/prometheus created
# service/prometheus created
# deployment.apps/prometheus created
# serviceaccount/grafana created
# configmap/grafana created
# service/grafana created
# deployment.apps/grafana created
# configmap/istio-grafana-dashboards created
# configmap/istio-services-grafana-dashboards created
# deployment.apps/jaeger created
# service/tracing created
# configmap/jaeger created
# service/zipkin created
# service/jaeger-collector created
# serviceaccount/kiali created
# configmap/kiali created
# clusterrole.rbac.authorization.k8s.io/kiali created
# clusterrolebinding.rbac.authorization.k8s.io/kiali created
# service/kiali created
# deployment.apps/kiali created

kubectl -n istio-system get pods | grep -E 'prometheus|grafana|jaeger|kiali'
# grafana-665dcbcb9b-5qcl8               1/1     Running   0          17m
# jaeger-d5f9f848-429qm                  1/1     Running   0          17m
# kiali-68568d476c-q9r7k                 1/1     Running   0          17m
# prometheus-65c465688f-pvb2m            2/2     Running   0          17m

# dashboard
istioctl dashboard kiali       # opens browser to Kiali
istioctl dashboard grafana     # opens browser to Grafana
istioctl dashboard prometheus  #
```

---

## Create Gateway

```sh
kubectl apply -f manifests/istio/monitoring/
```
