# Cockroach in Kubernetes

This image will run cockroachdb inside kubernetes

These environments variable should be provided
- SELECTOR the selector for cockroach peers

## _IMPORTANT!!_
- To start the cluster you need to start one first, than scale it up or add more node
- This container expect that you use port :26257 for cockroachdb

### Provided By
[Berdu, buat website dan toko online](https://berdu.id)
