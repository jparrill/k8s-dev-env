# k8s-dev-env
Quick dev/testing env for projects

## Prereqs

- Golang 1.17+
- kubeclt/oc clients ([Download](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/))

## Quickstart

- Deploy Kind cluster

```bash
make kind
```

- Deploy Prometheus in K8s cluster

```bash
make prom
```