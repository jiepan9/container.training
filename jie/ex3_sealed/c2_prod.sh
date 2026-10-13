# install sealed secrets
kubectl apply -f \
        https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.40.0/controller.yaml

# create namespace prod
kubectl create namespace prod

