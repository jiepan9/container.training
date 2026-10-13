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

# get the the cert of prod cluster and save it to a file named prod-cert.pem

# re-seal the secrets with the prod cluster cert
VAL=$(kubectl get secret logging-api-token -n dev -o jsonpath='{.data.token}' | base64 -d)
kubectl create secret generic logging-api-token  --from-literal=token="$VAL" --dry-run=client -o yaml | kubeseal --cert prod-cert.pem --scope cluster-wide --format yaml > sealedsecret-logging-api-token-prod.yaml

VAL=$(kubectl get secret database-password -n dev -o jsonpath='{.data.password}' | base64 -d)
kubectl create secret generic database-password  --from-literal=password="$VAL" --dry-run=client -o yaml | kubeseal --cert prod-cert.pem --scope cluster-wide --format yaml > sealedsecret-database-password-prod.yaml

cat sealedsecret-logging-api-token-prod.yaml sealedsecret-database-password-prod.yaml > sealedsecrets-prod.yaml
rm sealedsecret-logging-api-token-prod.yaml sealedsecret-database-password-prod.yaml

# on dev cluster export the key of the dev/staging cluster to a yaml file named dev-sealedsecret-key.yaml
kubectl get secret -n kube-system  -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml > dev-sealedsecret-key.yaml

# remove uid, resourceVersion, creationTimestamp, and annotations from the dev-sealedsecret-key.yaml file

# on prod cluster create a new secret named sealed-secrets-key in the kube-system namespace using the dev-sealedsecret-key.yaml file
