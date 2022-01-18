```sh
k get nodes
NAME                              STATUS   ROLES   AGE   VERSION
aks-default-50803829-vmss000000   Ready    agent   14h   v1.22.4
akswb2s000000                     Ready    agent   14h   v1.22.4
```

Use kubectl debug to run a container image on the node to connect to it.

```sh
kubectl debug node/aks-default-50803829-vmss000000 -it --image=mcr.microsoft.com/aks/fundamental/base-ubuntu:v0.0.11
```