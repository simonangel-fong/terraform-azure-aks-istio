
## Install Istio

```sh
helm repo add istio https://istio-release.storage.googleapis.com/charts
# "istio" has been added to your repositories
helm repo update istio
# Hang tight while we grab the latest from your chart repositories...
# ...Successfully got an update from the "istio" chart repository
# Update Complete. ⎈Happy Helming!⎈

kubectl create namespace istio-system

KUBECONFIG=./kubeconfig helm upgrade -i istio-base istio/base -n istio-system --set defaultRevision=default --wait --create-namespace

KUBECONFIG=./kubeconfig helm upgrade -i istiod istio/istiod -n istio-system --wait

KUBECONFIG=./kubeconfig helm upgrade -i istio-ingressgateway istio/gateway -n istio-system -f manifests/istio-gateway/values.yaml --wait

# enable sidercar injection
KUBECONFIG=./kubeconfig kubectl label namespace default istio-injection=enabled --overwrite


# confirm 
# Control plane + gateway pods are Running
KUBECONFIG=./kubeconfig kubectl -n istio-system get pods
# NAME                                   READY   STATUS    RESTARTS   AGE
# istio-ingressgateway-6cbc75f57-cv2q8   1/1     Running   0          7m43s
# istiod-6fdc665455-ztgf5                1/1     Running   0          13m

# Ingress LB has an external IP
KUBECONFIG=./kubeconfig kubectl -n istio-system get svc istio-ingressgateway
# NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                      AGE
# istio-ingressgateway   LoadBalancer   10.0.143.10   20.121.180.84   15021:32673/TCP,80:32341/TCP,443:30841/TCP   8m42s

# istioctl analyze should report no issues
KUBECONFIG=./kubeconfig istioctl analyze -n default
# ✔ No validation issues found when analyzing namespace: default.

# Save the ingress IP for phase 04
export INGRESS_IP=$(KUBECONFIG=./kubeconfig kubectl -n istio-system get svc istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "ingress IP: $INGRESS_IP"
# ingress IP: 20.121.180.84

```