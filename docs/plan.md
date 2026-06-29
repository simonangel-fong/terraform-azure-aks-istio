# Plan

[Back](../README.md)

## Goal

Practice core Istio service-mesh skills on AKS:

- Ingress gateway (north-south traffic)
- mTLS / TLS termination with cert-manager
- Observability (Kiali, Prometheus, Grafana)
- Traffic management (weighted routing, canary rollout)

## Use Cases

1. Load balancing + canary deployment, observed via Kiali
2. Ingress gateway exposing the app over HTTP
3. TLS termination at the gateway, certs issued by cert-manager
4. Metric collection with Prometheus, dashboards in Grafana

---

## Phase 01 — Provision AKS

- Provision the cluster with Terraform ([infra/](../infra/))
  - Resource group, VNet + subnet, AKS with system-assigned identity, Azure CNI
  - Helm + kubernetes providers wired to the new cluster
- Fetch kubeconfig and confirm node readiness
- **Verify**
  - `terraform -chdir=infra apply -auto-approve`
  - `kubectl get nodes` → all nodes `Ready`

---

## Phase 02 — Install Istio + enable injection

Install Istio **before** deploying the app so sidecars are injected from the start.

- Install Istio via Helm (`base`, `istiod`, `gateway` charts) into `istio-system`
- Label `default` namespace: `istio-injection=enabled`
- **Verify**
  - `kubectl -n istio-system get pods` → `istiod`, ingress gateway `Running`
  - `kubectl get ns default --show-labels` shows `istio-injection=enabled`
  - `kubectl get svc -n istio-system istio-ingressgateway` → external IP assigned

---

## Phase 03 — Deploy web app v1

- Minimal nginx app returning JSON
  - `GET /` → `{"app":"istio app","version":"1.0"}`
  - `GET /healthz` → `ok`
- Manifests: `Deployment` (2 replicas) + `ConfigMap` (nginx config) + `Service` (ClusterIP, port 80)
- Labels: `app=web`, `version=v1`
- **Verify**
  - `kubectl get deploy web -n default` → ready 2/2
  - `kubectl get pod -l app=web` → each pod shows **2/2** containers (app + istio-proxy)

---

## Phase 04 — Expose via Istio Gateway

- `Gateway` on the ingress controller, port 80, host `*` (or a chosen hostname)
- `VirtualService` routing host → `web` service
- **Verify**
  - `curl http://<ingress-ip>/` → returns v1 JSON
  - `curl http://<ingress-ip>/healthz` → `ok`

---

## Phase 05 — TLS at the gateway

- Install cert-manager via Helm into `cert-manager` namespace
- Create a `ClusterIssuer` (self-signed or Let's Encrypt staging — self-signed is simpler for practice)
- Issue a `Certificate` whose secret is mounted by the Istio gateway
- Update `Gateway` to add a port 443 server with `tls.mode: SIMPLE` referencing the cert secret
- Optionally redirect HTTP → HTTPS
- **Verify**
  - `kubectl -n istio-system get secret <tls-secret>` exists with `tls.crt`/`tls.key`
  - `curl -k https://<host>/` returns v1 JSON
  - `openssl s_client -connect <host>:443` shows the expected cert

---

## Phase 06 — Observability

- Install Kiali, Prometheus, and Grafana (Istio addons or Helm charts) into `istio-system`
- Generate traffic from a client pod:
  - `kubectl run curl --image=curlimages/curl -it --rm -- sh`
  - Loop: `while true; do curl -s http://web/; sleep 1; done`
- **Verify**
  - `istioctl dashboard kiali` → service graph shows `web` receiving traffic
  - `istioctl dashboard grafana` → Istio service dashboard shows RPS/latency for `web`
  - Prometheus targets page lists `istiod` and sidecar scrape targets as `UP`

---

## Phase 07 — Weighted load balancing (v1 + v2)

- Deploy `web-v2` with the same labels except `version=v2`, response `{"app":"istio app","version":"2.0"}`
- `DestinationRule` defines subsets `v1` and `v2` keyed on the `version` label
- `VirtualService` splits traffic **v1:v2 = 75:25** (i.e. v2 = 25%)
- **Verify**
  - Send 100 curls; v2 responses are roughly 25%
  - Kiali graph shows traffic flowing to both subsets in expected ratio

---

## Phase 08 — Canary rollout

Progressive shift from v1 → v2 by editing the `VirtualService` weights:

1. v1 80 / v2 20
2. v1 50 / v2 50
3. v1 0 / v2 100
4. Decommission v1 deployment once at 100% v2

- **Verify at each step**
  - Curl ratio matches the configured weights
  - Kiali shows the traffic split converging to v2
  - Error rate in Grafana stays flat across the rollout

---

## Phase 09 — A/B test (header-based routing)

Internal testers send a header and always land on v2; everyone else gets the 90/10 baseline.

- Deploy `web-v1`, `web-v2`
- `DestinationRule`: subsets `v1`/`v2`
- `VirtualService`: **two ordered `http` rules**
  1. **Match** `header: x-test: "true"` → 100% to subset `v2`
  2. **Default** (no match) → weighted split **v1 90 / v2 10**
- **Verify**
  - 100 curls **without** the header → ≈ 90 v1 / 10 v2
  - 20 curls **with** `-H "x-test: true"` → 20 × v2, zero v1
  - Kiali Graph (with "Request Distribution") shows two distinct flows from the ingress gateway

---

## Phase 10 — Traffic mirroring (shadowing)

Send 100% of live traffic to v1 (the response the client sees) and **fork a fire-and-forget copy** to v2. Mirrored responses are discarded — clients are unaffected, but v2 sees real production load for testing.

- Deploy `web-v1`, `web-v2`
- `DestinationRule`: subsets `v1`/`v2` (reused from phase 07)
- `VirtualService`:
  - `route` → subset `v1` (weight 100) — serves the client
  - `mirror` → subset `v2`, `mirrorPercentage.value: 100` — shadow copy
- **Verify**
  - Every client response is v1 (`"version":"1.0"`)
  - `kubectl logs -l version=v2 -c istio-proxy` shows incoming requests on v2 pods
  - Kiali Graph shows a dashed edge from `web` → `v2` labeled *mirrored*
  - Grafana: v2 RPS roughly equals v1 RPS, but v1's response codes are what reach the gateway

---

## Cleanup

- `helm uninstall` addons → Istio → cert-manager
- `terraform -chdir=infra destroy -auto-approve`
- Confirm the resource group is gone in the Azure portal
