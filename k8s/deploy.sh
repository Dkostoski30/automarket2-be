#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FE_ROOT="${FE_DIR:-$(cd "$HOME/WebstormProjects/automarket2-FE" 2>/dev/null && pwd || echo "")}"
CLUSTER_NAME="automarket"

echo "=== AutoMarket Kubernetes Deployment (k3d) ==="
echo "Project root: $PROJECT_ROOT"

# ── 1. Create k3d cluster ───────────────────────────────────────
if k3d cluster list 2>/dev/null | grep -q "$CLUSTER_NAME"; then
  echo "Cluster '$CLUSTER_NAME' already exists."
  # Ensure kubeconfig is set
  k3d kubeconfig merge "$CLUSTER_NAME" --kubeconfig-switch-context 2>/dev/null || true
else
  echo "Creating k3d cluster '$CLUSTER_NAME'..."
  k3d cluster create "$CLUSTER_NAME" \
    --image rancher/k3s:v1.31.6-k3s1 \
    --port "80:80@loadbalancer" \
    --port "443:443@loadbalancer" \
    --k3s-arg "--disable=traefik@server:0" \
    --agents 0 \
    --servers 1
fi

# Fix kubeconfig: on Windows, host.docker.internal may not resolve — use 127.0.0.1
CURRENT_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' 2>/dev/null || true)
if echo "$CURRENT_SERVER" | grep -q "host.docker.internal"; then
  FIXED_SERVER=$(echo "$CURRENT_SERVER" | sed 's|host.docker.internal|127.0.0.1|')
  echo "Fixing kubeconfig: $CURRENT_SERVER -> $FIXED_SERVER"
  kubectl config set-cluster "k3d-${CLUSTER_NAME}" --server="$FIXED_SERVER"
fi

# Install nginx ingress controller (lightweight, matches existing manifests)
echo "Installing nginx ingress controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml 2>/dev/null || true
echo "Waiting for ingress controller..."
kubectl -n ingress-nginx wait --for=condition=available deployment/ingress-nginx-controller --timeout=120s 2>/dev/null || true

# ── 2. Build Docker images and import into k3d ──────────────────
echo ""
echo "=== Building Docker images ==="
echo "This will take a few minutes on first run..."
echo ""

SERVICES=(auth-service listing-service blog-service inquiry-service payment-service notification-service gateway)

for svc in "${SERVICES[@]}"; do
  echo "Building $svc..."
  docker build -t "automarket/automarket-${svc}:latest" \
    -f "${PROJECT_ROOT}/${svc}/Dockerfile" \
    "$PROJECT_ROOT" --quiet
  echo "  ✓ $svc built"
done

# Build frontend if repo exists
if [ -n "$FE_ROOT" ] && [ -f "$FE_ROOT/Dockerfile" ]; then
  echo "Building frontend..."
  docker build -t "automarket/automarket-frontend:latest" \
    "$FE_ROOT" --quiet
  echo "  ✓ frontend built"
else
  echo "⚠ Frontend repo not found at $FE_ROOT — skipping frontend image build"
fi

echo ""
echo "Importing images into k3d cluster..."
IMAGES=()
for svc in "${SERVICES[@]}"; do
  IMAGES+=("automarket/automarket-${svc}:latest")
done
if docker image inspect automarket/automarket-frontend:latest >/dev/null 2>&1; then
  IMAGES+=("automarket/automarket-frontend:latest")
fi
k3d image import "${IMAGES[@]}" -c "$CLUSTER_NAME"
echo "All images imported."
echo ""

# ── 3. Apply namespace, config, secrets ─────────────────────────
echo "Creating namespace..."
kubectl apply -f "$SCRIPT_DIR/namespace.yml"

echo "Applying config and secrets..."
kubectl apply -f "$SCRIPT_DIR/configmap.yml"
kubectl apply -f "$SCRIPT_DIR/secret.yml"

# ── 4. Deploy infrastructure ───────────────────────────────────
echo "Deploying infrastructure..."
kubectl apply -f "$SCRIPT_DIR/infrastructure/postgres-configmap.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/postgres-statefulset.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/postgres-service.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/redis-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/redis-service.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/kafka-service.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/kafka-statefulset.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/mailhog-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/mailhog-service.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/prometheus-configmap.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/prometheus-rules-configmap.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/prometheus-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/prometheus-service.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/grafana-datasources.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/grafana-dashboards-configmap.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/grafana-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/grafana-service.yml"

# Wait for infrastructure to be ready
echo "Waiting for infrastructure to be ready..."
kubectl -n automarket wait --for=condition=ready pod -l app=postgres --timeout=120s
kubectl -n automarket wait --for=condition=ready pod -l app=redis --timeout=60s
kubectl -n automarket wait --for=condition=ready pod -l app=kafka --timeout=180s

# ── 5. Deploy application services ─────────────────────────────
echo "Deploying application services..."
kubectl apply -f "$SCRIPT_DIR/services/uploads-pvc.yml"
kubectl apply -f "$SCRIPT_DIR/services/blog-uploads-pvc.yml"
kubectl apply -f "$SCRIPT_DIR/services/auth-service-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/services/auth-service-service.yml"
kubectl apply -f "$SCRIPT_DIR/services/listing-service-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/services/listing-service-service.yml"
kubectl apply -f "$SCRIPT_DIR/services/blog-service-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/services/blog-service-service.yml"
kubectl apply -f "$SCRIPT_DIR/services/inquiry-service-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/services/inquiry-service-service.yml"
kubectl apply -f "$SCRIPT_DIR/services/payment-service-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/services/payment-service-service.yml"
kubectl apply -f "$SCRIPT_DIR/services/notification-service-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/services/notification-service-service.yml"
kubectl apply -f "$SCRIPT_DIR/services/gateway-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/services/gateway-service.yml"
kubectl apply -f "$SCRIPT_DIR/services/frontend-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/services/frontend-service.yml"

# ── 6. Apply ingress ───────────────────────────────────────────
echo "Applying ingress..."
kubectl apply -f "$SCRIPT_DIR/ingress.yml"

# ── 6b. Autoscaling and disruption budgets ─────────────────────
echo "Applying HPAs and PodDisruptionBudgets..."
kubectl apply -f "$SCRIPT_DIR/autoscaling.yml"

# ── 6c. Network policies (opt-in) ──────────────────────────────
# Restricts backend services to gateway + Prometheus traffic. Off by default:
# NetworkPolicy support depends on the CNI, and if the kubelet's probes get
# caught by it every pod fails readiness at once, which is a confusing way to
# lose a demo. Turn it on deliberately and check the pods stay ready:
#
#   APPLY_NETWORK_POLICIES=1 ./deploy.sh
#
# The shared-secret check in GatewayAuthFilter is the actual authorization fix;
# this is defence in depth on top of it.
if [ "${APPLY_NETWORK_POLICIES:-0}" = "1" ]; then
  echo "Applying network policies..."
  kubectl apply -f "$SCRIPT_DIR/networkpolicy.yml"
else
  echo "Skipping network policies (set APPLY_NETWORK_POLICIES=1 to apply)."
fi

# ── 7. Print status ───────────────────────────────────────────
echo ""
echo "=== Deployment complete ==="
echo ""
echo "Waiting for services to start (this may take 1-2 minutes)..."
kubectl -n automarket wait --for=condition=ready pod -l app=auth-service --timeout=180s 2>/dev/null || true
kubectl -n automarket wait --for=condition=ready pod -l app=listing-service --timeout=180s 2>/dev/null || true
kubectl -n automarket wait --for=condition=ready pod -l app=gateway --timeout=180s 2>/dev/null || true

echo ""
kubectl -n automarket get pods
echo ""

echo "Add this to C:\\Windows\\System32\\drivers\\etc\\hosts:"
echo "  127.0.0.1 automarket.local"
echo ""
echo "Access:"
echo "  Frontend:  http://automarket.local"
echo "  API:       http://automarket.local/api/v1/reference/car-brands"
echo ""
echo "Monitoring (run in separate terminals):"
echo "  kubectl -n automarket port-forward svc/prometheus 9090:9090"
echo "  kubectl -n automarket port-forward svc/grafana 3000:3000"
echo "  Grafana: http://localhost:3000 (admin/admin)"
echo ""
echo "Cleanup: k3d cluster delete $CLUSTER_NAME"
echo ""
echo "Check pod status:"
echo "  kubectl -n automarket get pods"
