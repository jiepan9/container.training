mkdir ex-netpol
cd ex-netpol
cp ~/container.training/k8s/dockercoins.yaml .
ls ..
cp ../netpol-namespace.yaml .
ls
mv netpol-namespace.yaml networkpolicies.yaml
vim networkpolicies.yaml
ls
vim dockercoins.yaml
k apply -f .
k krew install klock
k klock pods
watch kubectl get pods
k klock pods
stern worker
stern .
k get svc
curl webui.ex-netpol.svc
curl rng.ex-netpol.svc
ls -l
vim networkpolicies.yaml
k apply -f .
k explain spec.podSelector.matchExpressions[0].operator
k explain netpol.spec.podSelector.matchExpressions[0].operator
k explain netpol.spec.podSelector.matchExpressions.operator
vim networkpolicies.yaml
k apply -f .
k create deployment blue --image jpetazzo/color
k get pods -o wide
k get pods -o wide
curl 100.64.2.155
k edit deploy blue
k get pods
k get pods
k get pods -o wide
curl 100.64.1.250
vim networkpolicies.yaml
k apply -f .
curl 100.64.1.250
k create deployment green --image jpetazzo/color
k get pods -o wide
curl 100.64.2.166