# on self hosted k8s cluster (kubeadm)

# install Gateway API CRDs
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.3/standard-install.yaml

# install Traefik with the Gateway API provider
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install traefik traefik/traefik -n traefik --create-namespace \
  --set providers.kubernetesGateway.enabled=true \
  --set service.type=LoadBalancer

# no cloud load balancer on kubeadm: bind the Service to the node IPs
# so that ports 80/443 are reachable (the public DNS records point to these nodes)
kubectl patch svc traefik -n traefik -p '{"spec":{"externalIPs":["10.10.2.144","10.10.2.58","10.10.1.234","10.10.3.104"]}}'

# install cert-manager (with Gateway API support)
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace \
  --set crds.enabled=true --set config.apiVersion=controller.config.cert-manager.io/v1alpha1 \
  --set config.kind=ControllerConfiguration --set config.enableGatewayAPI=true
kubectl wait -n cert-manager --for=condition=Available deployment --all --timeout=120s

# Let's Encrypt issuers (the solvers use the Gateway "web")
kubectl apply -f letsencrypt-staging.yaml
kubectl apply -f letsencrypt-prod.yaml

# our own Gateway (HTTP + HTTPS listeners, certificate requested by cert-manager)
kubectl apply -f gateway.yaml

# create a service for the existing deployment app
kubectl expose deployment app -n staging --port 80

# route staging.wichita-ks.xyz to the app
kubectl apply -f http_route-staging.yaml

# check
kubectl get clusterissuer
kubectl get gateway,certificate -n traefik
kubectl get httproute -n staging
curl -I http://staging.wichita-ks.xyz/
curl -kI https://staging.wichita-ks.xyz/
