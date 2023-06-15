DIR := ${PWD}
RUNTIME ?= docker
DOMAIN ?= "test.com"
CHECK ?= "true"
OLM_VERSION ?= "v0.24.0"
CS_VERSION ?= "v4.13"
PULL_SECRET ?= ""

all: kind prom hypershift olm

.PHONY: kind
kind:
	hack/kind/deploy-kind.sh

.PHONY: prom
prom:
	hack/prom/deploy-prom.sh

.PHONY: hypershift
hypershift:
	hack/hypershift/deploy-hypershift.sh $(DOMAIN)

.PHONY: olm
olm:
	hack/olm/deploy-olm.sh $(OLM_VERSION) $(CS_VERSION) $(PULL_SECRET)

.PHONY: operators
operators:
	hack/olm/deploy-dep-ops.sh