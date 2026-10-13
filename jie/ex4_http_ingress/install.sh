# install Gateway API CRD
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.3/standard-install.yaml

# install Traefik

helm repo add traefik https://traefik.github.io/charts
helm repo update
helm search repo traefik/traefik

helm upgrade --install traefik traefik/traefik -n traefik --create-namespace \
  --set providers.kubernetesGateway.enabled=true
helm upgrade traefik traefik/traefik -n traefik --reuse-values --set service.type=NodePort
helm upgrade traefik traefik/traefik -n traefik --reuse-values --set service.type=LoadBalancer

kubectl patch svc traefik -n traefik -p '{"spec":{"externalIPs":["10.10.2.144"]}}'
kubectl patch svc traefik -n traefik -p '{"spec":{"externalIPs":null}}'

kubectl patch svc traefik -n traefik -p '{"spec":{"externalIPs":["45.140.109.151"]}}'

# create a service for existing deployment app
k expose app -n staging --port 80

# allow all namespaces to use the traefik-gateway
kubectl patch gateway traefik-gateway -n traefik --type=json \
  -p='[{"op":"add","path":"/spec/listeners/0/allowedRoutes","value":{"namespaces":{"from":"All"}}}]'