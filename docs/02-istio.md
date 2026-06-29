# Istio with AKS - Install Istio

[Back](../README.md)

- [Istio with AKS - Install Istio](#istio-with-aks---install-istio)
  - [Install Istio](#install-istio)

---

## Install Istio

```sh
export KUBECONFIG=~/kubeconfig

helm repo add istio https://istio-release.storage.googleapis.com/charts
# "istio" has been added to your repositories
helm repo update istio
# Hang tight while we grab the latest from your chart repositories...
# ...Successfully got an update from the "istio" chart repository
# Update Complete. ⎈Happy Helming!⎈

helm search repo istio
# NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
# bitnami/wavefront-adapter-for-istio     2.0.6           0.1.5           DEPRECATED Wavefront Adapter for Istio is an ad...
# istio/istiod                            1.30.2          1.30.2          Helm chart for istio control plane
# istio/istiod-remote                     1.23.6          1.23.6          Helm chart for a remote cluster using an extern...
# istio/ambient                           1.30.2          1.30.2          Helm umbrella chart for ambient
# istio/base                              1.30.2          1.30.2          Helm chart for deploying Istio cluster resource...
# istio/cni                               1.30.2          1.30.2          Helm chart for istio-cni components
# istio/gateway                           1.30.2          1.30.2          Helm chart for deploying Istio gateways
# istio/ztunnel                           1.30.2          1.30.2          Helm chart for istio ztunnel components

# install istio base
helm upgrade -i istio-base istio/base -n istio-system --set defaultRevision=default --wait --create-namespace

# install istio istiod
helm upgrade -i istiod istio/istiod -n istio-system --wait

# install istio gateway
helm upgrade -i istio-ingressgateway istio/gateway -n istio-ingress -f manifests/istio/helm/values.yaml --create-namespace --wait

# confirm: control plane + gateway pods are Running
kubectl -n istio-system get pods
# NAME                                   READY   STATUS    RESTARTS   AGE
# istio-ingressgateway-6cbc75f57-cv2q8   1/1     Running   0          7m43s
# istiod-6fdc665455-ztgf5                1/1     Running   0          13m

# Ingress LB has an external IP
kubectl -n istio-ingress get svc istio-ingressgateway
# NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                      AGE
# istio-ingressgateway   LoadBalancer   10.0.143.10   20.121.180.84   15021:32673/TCP,80:32341/TCP,443:30841/TCP   8m42s

# istioctl analyze should report no issues
istioctl analyze -n default
# ✔ No validation issues found when analyzing namespace: default.

# Save the ingress IP for phase 04
export INGRESS_IP=$(kubectl -n istio-ingress get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "ingress IP: $INGRESS_IP"
# ingress IP: 20.121.180.84

```
