mkdir ex-rbac
cd ex-rbac
k create ns alice
k create ns bob
k create rolebinding alice --namespace alice --clusterrole admin -o yaml --dry-run
k create rolebinding alice --namespace alice --clusterrole admin -o yaml --dry-run > user-alice.yaml
k create rolebinding alice --namespace alice --clusterrole admin -o yaml --dry-run
k create rolebinding alice --namespace alice --clusterrole admin -o yaml --dry-run --user alice
k create rolebinding alice --namespace alice --clusterrole admin -o yaml --dry-run --user alice > user-alice.yaml
k apply -f .
k --as alice -n alice create deployment blue --image jpetazzo/color
k --as bob -n alice create deployment blue --image jpetazzo/color
k edit rolebindings.rbac.authorization.k8s.io alice -n alice
ls
vim user-alice.yaml
k apply -f .
vim user-alice.yaml
k apply -f .
vim user-alice.yaml
k apply -f .
vim user-alice.yaml
k apply -f .
vim ali
vim user-alice.yaml
cp user-alice.yaml user-bob.yaml
vim user-bob.yaml
k apply -f .
k --as bob -n bob create deployment blue --image jpetazzo/color
k --as alice -n bob create deployment green --image jpetazzo/color
k --as alice -n bob get pods
k --as alice get nodes
k create clusterrole alice --help
k create clusterrole alice --verb=get,list,watch --resource=nodes -o yaml --dry-run
k create clusterrole alice --verb=get,list,watch --resource=nodes -o yaml --dry-run >> user-alice.yaml
k create clusterrolebinding alice --clusterrole=alice --user=alice -o yaml --dry-run
k create clusterrolebinding alice --clusterrole=alice --user=alice -o yaml --dry-run >> user-alice.yaml
vim user-alice.yaml
k apply -f .
k --as alice get nodes
k --as bob get nodes
k --as alice label nodes scw-qwhd-113-x86-7ac7cef8da0d4f698312136b19dbf asdf=asdf