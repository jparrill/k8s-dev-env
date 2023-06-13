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

- Deploy Hypershift (for agent provider)

```bash
make hypershift
```

This option can use a domain for certificate generation that hypershift will use to generate other HostedClusters

```bash
DOMAIN="adrogallop.io" make hypershift
```

This other option will allow you to pass through all the checks that prvents an automatically deployment without human intervention:

```bash
CHECK="false" make hypershift
```