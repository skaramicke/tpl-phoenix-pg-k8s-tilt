# Variables

KIND_CLUSTER := tpl-phoenix-pg-k8s-tilt


## Help section

.PHONY: help
help: ## Show this help message
	@awk '\
		/^## / { \
			header = substr($$0, 4); \
			printf "\n\033[1m%s\033[0m\n", header; \
			next; \
		} \
		/^[a-zA-Z0-9_.-]+:.*## / { \
			match($$0, /^[a-zA-Z0-9_.-]+/); \
			t = substr($$0, RSTART, RLENGTH); \
			desc = $$0; sub(/^.*## /, "", desc); \
			printf "  \033[36m%-20s\033[0m %s\n", t, desc; \
		}' $(MAKEFILE_LIST)


## Development Environment

.PHONY: tilt
tilt: kubectl-context ## Start the development environment with Tilt
	tilt up

.PHONY: clean
clean: ## Reset the development environment
	kind delete cluster --name $(KIND_CLUSTER) || true


## Development environment setup

.PHONY: kind
kind: ## Create a local kind cluster
	kind create cluster --config=./kind.config.yaml || true

.PHONY: kubectl-context
kubectl-context: kind ## Switch kubectl context to the kind cluster
	kubectl config use-context kind-$(KIND_CLUSTER)


## Create a new release

.PHONY: release 
release: ## Release a new patch version by default.
	$(MAKE) patch


## Release a specific semver version

# Get the latest tag number
LATEST_TAG := $(shell git describe --abbrev=0 --tags 2>/dev/null)
CURRENT_TAG := $(or $(LATEST_TAG),v0.0.0)

# Function to increment version parts directly within targets
define increment_patch
$(shell echo $(1) | sed 's/^v//' | awk -F. '{ $$3 += 1; print "v"$$1"."$$2"."$$3 }')
endef

define increment_minor
$(shell echo $(1) | sed 's/^v//' | awk -F. '{ $$2 += 1; $$3=0; print "v"$$1"."$$2"."$$3 }')
endef

define increment_major
$(shell echo $(1) | sed 's/^v//' | awk -F. '{ $$1 += 1; $$2=0; $$3=0; print "v"$$1"."$$2"."$$3 }')
endef

# Function to create and push the new tag (echo commands for demonstration)
define tag_version
	git tag -a $(1) -m "Version $(1)"
	git push origin $(1)
endef

# Targets for version increments
.PHONY: patch minor major release
patch: ## Release a new patch version. Increment last digit, signifying non breaking bug fixes.
	$(eval NEW_TAG := $(call increment_patch,$(CURRENT_TAG)))
	$(call tag_version,$(NEW_TAG))

minor: ## Release a new minor version. Increment middle digit, signifying new features but backwards compatible.
	$(eval NEW_TAG := $(call increment_minor,$(CURRENT_TAG)))
	$(call tag_version,$(NEW_TAG))

major: ## Release a new major version. Increment first digit, signifying breaking changes like incompatible API changes.
	$(eval NEW_TAG := $(call increment_major,$(CURRENT_TAG)))
	$(call tag_version,$(NEW_TAG))
