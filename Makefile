DIR := ${PWD}
RUNTIME ?= docker

all: kind prom

.PHONY: kind
kind:
	hack/kind/deploy-kind.sh

.PHONY: prom
prom:
	hack/prom/deploy-prom.sh
