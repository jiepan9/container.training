# install sealed secrets
kubectl apply -f \
        https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.40.0/controller.yaml

kubectl create namespace dev
# create secrets logging-api-token and database-password

kubectl create secret generic logging-api-token -n dev --from-literal=token=your-api-token --dry-run=client -o yaml | kubeseal -n dev --format yaml > sealedsecret-logging-api-token.yaml
kubectl create secret generic database-password -n dev --from-literal=password=your-database-password --dry-run=client -o yaml | kubeseal -n dev --format yaml > sealedsecret-database-password.yaml

# create a deployment that uses the sealed secrets
kubectl create deployment red -n dev --image jpetazzo/color
kubectl set env deployment/red -n dev --from=secret/logging-api-token
kubectl set env deployment/red -n dev --from=secret/database-password