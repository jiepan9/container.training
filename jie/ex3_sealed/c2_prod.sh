# install sealed secrets
kubectl apply -f \
        https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.40.0/controller.yaml

# create namespace prod
kubectl create namespace prod

# create sealed secrets generated using prod cluster cert
kubectl apply -f sealedsecrets-prod.yaml -n prod

# create a deployment that uses the sealed secrets
kubectl apply -f deployment.yaml -n prod