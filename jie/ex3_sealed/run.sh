# install sealed secrets
kubectl apply -f \
        https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.40.0/controller.yaml

kubectl create namespace dev
# create secrets logging-api-token and database-password

kubectl create secret generic logging-api-token -n dev --from-literal=token=your-api-token --dry-run=client -o yaml | kubeseal -n dev --format yaml > sealedsecret-logging-api-token.yaml
kubectl create secret generic database-password -n dev --from-literal=password=your-database-password --dry-run=client -o yaml | kubeseal -n dev --format yaml > sealedsecret-database-password.yaml

# create a deployment that uses the sealed secrets
kubectl create deployment app -n dev --image jpetazzo/color
kubectl set env deployment/app -n dev --from=secret/logging-api-token
kubectl set env deployment/app -n dev --from=secret/database-password

# verify that the secrets are available in the deployment
kubectl exec -n dev deployment/app -- env | grep TOKEN
kubectl exec -n dev deployment/app -- env | grep PASSWORD

# generate yaml file with deployment and secrets
kubectl get deployment app -n dev -o yaml > deployment.yaml

# remove uid, creationTimestamp, resourceVersion, generation, annotations, and whole status from the deployment.yaml file
sed -i '/uid:/d' deployment.yaml
sed -i '/creationTimestamp:/d' deployment.yaml
sed -i '/resourceVersion:/d' deployment.yaml
sed -i '/generation:/d' deployment.yaml
sed -i '/annotations:/d' deployment.yaml
sed -i '/status:/,/^$/d' deployment.yaml

# create a new sealed secret for cluster-wide use
kubectl create secret generic logging-api-token --from-literal=token=test-api-token --dry-run=client -o yaml | kubeseal --scope cluster-wide --format yaml > sealedsecret-logging-api-token-clusterwide.yaml
kubectl create secret generic database-password --from-literal=password=test-database-password --dry-run=client -o yaml | kubeseal --scope cluster-wide --format yaml > sealedsecret-database-password-clusterwide.yaml

# combine the two sealed secrets into a single yaml file
cat sealedsecret-logging-api-token-clusterwide.yaml sealedsecret-database-password-clusterwide.yaml > sealedsecrets.yaml

# apply the sealed secrets and deployment to dev namespace
kubectl create namespace dev
kubectl apply -f sealedsecrets.yaml -n dev
kubectl apply -f deployment.yaml -n dev


# apply the sealed secrets and deployment to staging namespace
kubectl create namespace staging
kubectl apply -f sealedsecrets.yaml -n staging
kubectl apply -f deployment.yaml -n staging