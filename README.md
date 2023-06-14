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

- Deploy OLM, this is needed to deploy `agent-service-operator` and `hive-operator` in the nexts steps

```bash
make olm

OLM_VERSION="v0.24.0" make olm
```

If you want to enable private catalogSources from OCP you need to do this:

```bash
PULL_SECRET="<path to pull secret>" make olm

or

CS_VERSION="v4.12" PULL_SECRET="<path to pull secret>" make olm
```