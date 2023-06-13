DIR := ${PWD}
RUNTIME ?= docker
DOMAIN ?= "test.com"

all: kind prom hypershift

.PHONY: kind
kind:
	hack/kind/deploy-kind.sh

.PHONY: prom
prom:
	hack/prom/deploy-prom.sh

.PHONY: hypershift
hypershift:
	hack/hypershift/deploy-hypershift.sh $(DOMAIN)
