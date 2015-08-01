# Cockroach in Kubernetes

This image will run cockroachdb inside kubernetes

These environments variable should be provided
- KUBE_MASTER the address of kuberentes master, should not be a https
- SELECTOR the selector for the cockroach peers
- IDENTITY the IDENTITY file from the stores

CockroachDB will run on port 8080. The main store is ssd, To replace it, mount on /store dir. 

## _IMPORTANT!!_
For starting the cluster, first of all a pod should be started, if using replicationController replica should be 1. Then scale as you wish.


