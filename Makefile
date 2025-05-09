# Detect OS (Linux/macOS)
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')

# Detect ARCH (AMD64 or ARM64)
UNAME_P := $(shell uname -p)
ARCH :=
ifeq ($(UNAME_P),x86_64)
	ARCH =amd64
endif
ifneq ($(filter arm%,$(UNAME_P)),)
	ARCH = arm64
endif

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)
KUSTOMIZE ?= $(LOCALBIN)/kustomize
YQ ?= $(LOCALBIN)/yq
HELM_DOCS_VERSION ?= 1.14.2
HELM_DOCS_REPO ?= https://github.com/norwoodj/helm-docs/releases/download/v$(HELM_DOCS_VERSION)/helm-docs_$(HELM_DOCS_VERSION)_$(OS)_$(ARCH).tar.gz


## Download `helm-docs` locally if necessary
# Improved helm-docs target with better readability and maintainability
.PHONY: helm-docs
helm-docs:
	@# Ensure the local bin directory exists
	@mkdir -p $(LOCALBIN)

	@# Check if helm-docs exists and matches the expected version
	@if [ -x "$(LOCALBIN)/helm-docs" ] && ! $(LOCALBIN)/helm-docs -v | grep -q $(HELM_DOCS_VERSION); then \
		echo "$(LOCALBIN)/helm-docs -v is not expected $(HELM_DOCS_VERSION). Removing it before installing."; \
		rm -f $(LOCALBIN)/helm-docs; \
	fi

	@# Download and install helm-docs if not present
	@if [ ! -s "$(LOCALBIN)/helm-docs" ]; then \
		echo "Downloading helm-docs $(HELM_DOCS_VERSION) to $(LOCALBIN)"; \
		curl -L $(HELM_DOCS_REPO) -o $(LOCALBIN)/helm-docs.tar.gz; \
		tar -xzf $(LOCALBIN)/helm-docs.tar.gz -C $(LOCALBIN) helm-docs; \
		rm $(LOCALBIN)/helm-docs.tar.gz; \
		chmod +x $(LOCALBIN)/helm-docs; \
	fi

	@# Run helm-docs
	@$(LOCALBIN)/helm-docs -c charts/kubernetes-operations