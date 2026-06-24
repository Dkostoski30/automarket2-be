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
kubectl apply -f "$SCRIPT_DIR/infrastructure/rabbitmq-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/rabbitmq-service.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/mailhog-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/mailhog-service.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/prometheus-configmap.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/prometheus-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/prometheus-service.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/grafana-datasources.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/grafana-deployment.yml"
kubectl apply -f "$SCRIPT_DIR/infrastructure/grafana-service.yml"

# Wait for infrastructure to be ready
echo "Waiting for infrastructure to be ready..."
kubectl -n automarket wait --for=condition=ready pod -l app=postgres --timeout=120s
kubectl -n automarket wait --for=condition=ready pod -l app=redis --timeout=60s
kubectl -n automarket wait --for=condition=ready pod -l app=rabbitmq --timeout=120s

# ── 5. Deploy application services ─────────────────────────────
echo "Deploying application services..."
kubectl apply -f "$SCRIPT_DIR/services/uploads-pvc.yml"
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

# ── 7. Install Argo CD ─────────────────────────────────────────
echo "Installing Argo CD..."
kubectl apply -f "$SCRIPT_DIR/argocd/install.yml"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml 2>/dev/null || true
echo "Waiting for Argo CD server to be ready..."
kubectl -n argocd wait --for=condition=available deployment/argocd-server --timeout=300s

# Apply Argo CD Application
echo "Creating Argo CD Application..."
kubectl apply -f "$SCRIPT_DIR/argocd/application.yml"

# ── 8. Print status ────────────────────────────────────────────
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
echo "Argo CD UI:"
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "<not yet ready>")
echo "  Run: kubectl port-forward svc/argocd-server -n argocd 9090:443"
echo "  Open: https://localhost:9090"
echo "  Username: admin"
echo "  Password: $ARGOCD_PASSWORD"
echo ""
echo "Cleanup: k3d cluster delete $CLUSTER_NAME"
echo ""
echo "Check pod status:"
echo "  kubectl -n automarket get pods"
