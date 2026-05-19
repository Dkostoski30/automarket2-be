#!/bin/bash
set -e

echo "=== AutoMarket Kubernetes Deployment ==="

# Start Minikube if not running
if ! minikube status | grep -q "Running"; then
  echo "Starting Minikube..."
  minikube start --memory=8192 --cpus=4
fi

# Enable ingress addon
echo "Enabling ingress addon..."
minikube addons enable ingress

# Apply namespace
echo "Creating namespace..."
kubectl apply -f k8s/namespace.yml

# Apply configmap and secrets
echo "Applying config and secrets..."
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secret.yml

# Apply infrastructure
echo "Deploying infrastructure..."
kubectl apply -f k8s/infrastructure/postgres-configmap.yml
kubectl apply -f k8s/infrastructure/postgres-statefulset.yml
kubectl apply -f k8s/infrastructure/postgres-service.yml
kubectl apply -f k8s/infrastructure/redis-deployment.yml
kubectl apply -f k8s/infrastructure/redis-service.yml
kubectl apply -f k8s/infrastructure/rabbitmq-deployment.yml
kubectl apply -f k8s/infrastructure/rabbitmq-service.yml
kubectl apply -f k8s/infrastructure/mailhog-deployment.yml
kubectl apply -f k8s/infrastructure/mailhog-service.yml

# Wait for infrastructure to be ready
echo "Waiting for infrastructure to be ready..."
kubectl -n automarket wait --for=condition=ready pod -l app=postgres --timeout=120s
kubectl -n automarket wait --for=condition=ready pod -l app=redis --timeout=60s
kubectl -n automarket wait --for=condition=ready pod -l app=rabbitmq --timeout=120s

# Apply application services
echo "Deploying application services..."
kubectl apply -f k8s/services/uploads-pvc.yml
kubectl apply -f k8s/services/auth-service-deployment.yml
kubectl apply -f k8s/services/auth-service-service.yml
kubectl apply -f k8s/services/listing-service-deployment.yml
kubectl apply -f k8s/services/listing-service-service.yml
kubectl apply -f k8s/services/blog-service-deployment.yml
kubectl apply -f k8s/services/blog-service-service.yml
kubectl apply -f k8s/services/inquiry-service-deployment.yml
kubectl apply -f k8s/services/inquiry-service-service.yml
kubectl apply -f k8s/services/reference-service-deployment.yml
kubectl apply -f k8s/services/reference-service-service.yml
kubectl apply -f k8s/services/payment-service-deployment.yml
kubectl apply -f k8s/services/payment-service-service.yml
kubectl apply -f k8s/services/notification-service-deployment.yml
kubectl apply -f k8s/services/notification-service-service.yml
kubectl apply -f k8s/services/gateway-deployment.yml
kubectl apply -f k8s/services/gateway-service.yml
kubectl apply -f k8s/services/frontend-deployment.yml
kubectl apply -f k8s/services/frontend-service.yml

# Apply ingress
echo "Applying ingress..."
kubectl apply -f k8s/ingress.yml

# Print status
echo ""
echo "=== Deployment complete ==="
echo ""
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"
echo ""
echo "Add the following line to your /etc/hosts (or C:\\Windows\\System32\\drivers\\etc\\hosts):"
echo "  $MINIKUBE_IP automarket.local"
echo ""
echo "Then access:"
echo "  Frontend: http://automarket.local"
echo "  API:      http://automarket.local/api/v1/references/brands"
echo ""
echo "Check pod status:"
echo "  kubectl -n automarket get pods"
