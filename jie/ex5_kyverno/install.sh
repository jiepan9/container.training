# install kyverno   
helm upgrade --install --repo https://kyverno.github.io/kyverno/ \
  --namespace kyverno --create-namespace kyverno kyverno