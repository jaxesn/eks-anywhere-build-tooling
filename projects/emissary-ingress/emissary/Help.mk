


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `emissary`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file
patch-repo: ## Patch upstream repo with patches in patches directory

##@ Binary Targets
binaries: ## Build all binaries: `busyambassador capabilities_wrapper example-envoy-metrics-sink k8sregistryctl kat-client kat-server` for `linux/amd64 linux/arm64`
_output/bin/emissary/linux-amd64/busyambassador: ## Build `_output/bin/emissary/linux-amd64/busyambassador`
_output/bin/emissary/linux-amd64/capabilities_wrapper: ## Build `_output/bin/emissary/linux-amd64/capabilities_wrapper`
_output/bin/emissary/linux-amd64/example-envoy-metrics-sink: ## Build `_output/bin/emissary/linux-amd64/example-envoy-metrics-sink`
_output/bin/emissary/linux-amd64/k8sregistryctl: ## Build `_output/bin/emissary/linux-amd64/k8sregistryctl`
_output/bin/emissary/linux-amd64/kat-client: ## Build `_output/bin/emissary/linux-amd64/kat-client`
_output/bin/emissary/linux-amd64/kat-server: ## Build `_output/bin/emissary/linux-amd64/kat-server`
_output/bin/emissary/linux-arm64/busyambassador: ## Build `_output/bin/emissary/linux-arm64/busyambassador`
_output/bin/emissary/linux-arm64/capabilities_wrapper: ## Build `_output/bin/emissary/linux-arm64/capabilities_wrapper`
_output/bin/emissary/linux-arm64/example-envoy-metrics-sink: ## Build `_output/bin/emissary/linux-arm64/example-envoy-metrics-sink`
_output/bin/emissary/linux-arm64/k8sregistryctl: ## Build `_output/bin/emissary/linux-arm64/k8sregistryctl`
_output/bin/emissary/linux-arm64/kat-client: ## Build `_output/bin/emissary/linux-arm64/kat-client`
_output/bin/emissary/linux-arm64/kat-server: ## Build `_output/bin/emissary/linux-arm64/kat-server`

##@ Image Targets
local-images: ## Builds `emissary/images/amd64` as oci tars for presumbit validation
images: ## Pushes `emissary/images/push` to IMAGE_REPO
emissary/images/amd64: ## Builds/pushes `emissary/images/amd64`
emissary/images/push: ## Builds/pushes `emissary/images/push`

##@ Helm Targets
helm/build: ## Build helm chart
helm/push: ## Build helm chart and push to registry defined in IMAGE_REPO.

##@ Checksum Targets
checksums: ## Update checksums file based on currently built binaries.
validate-checksums: # Validate checksums of currently built binaries against checksums file.
all-checksums: ## Update checksums files for all RELEASE_BRANCHes.

##@ Run in Docker Targets
run-all-attributions-in-docker: ## Run `all-attributions` in docker builder container
run-all-attributions-checksums-in-docker: ## Run `all-attributions-checksums` in docker builder container
run-all-checksums-in-docker: ## Run `all-checksums` in docker builder container
run-attribution-in-docker: ## Run `attribution` in docker builder container
run-attribution-checksums-in-docker: ## Run `attribution-checksums` in docker builder container
run-binaries-in-docker: ## Run `binaries` in docker builder container
run-checksums-in-docker: ## Run `checksums` in docker builder container
run-clean-in-docker: ## Run `clean` in docker builder container
run-clean-go-cache-in-docker: ## Run `clean-go-cache` in docker builder container

##@ License Targets
gather-licenses: ## Helper to call $(GATHER_LICENSES_TARGETS) which gathers all licenses
attribution: ## Generates attribution from licenses gathered during `gather-licenses`.
attribution-pr: ## Generates PR to update attribution files for projects
attribution-checksums: ## Update attribution and checksums files.
all-attributions: ## Update attribution files for all RELEASE_BRANCHes.
all-attributions-checksums: ## Update attribution and checksums files for all RELEASE_BRANCHes.

##@ Clean Targets
clean: ## Removes source and _output directory
clean-repo: ## Removes source directory

##@ Helpers
help: ## Display this help
add-generated-help-block: ## Add or update generated help block to document project make file and support shell auto completion

##@Update Helpers
run-target-in-docker: ## Run `MAKE_TARGET` using builder base docker container
stop-docker-builder: ## Clean up builder base docker container
generate: ## Update UPSTREAM_PROJECTS.yaml
update-go-mods: ## Update locally checked-in go sum to assist in vuln scanning
update-vendor-for-dep-patch: ## After bumping dep in go.mod file, uses generic vendor update script or one provided from upstream project
patch-for-dep-update: ## After bumping dep in go.mod file and updating vendor, generates patch
create-ecr-repos: ## Create repos in ECR for project images for local testing

##@ Build Targets
build: ## Called via prow presubmit, calls `github-rate-limit-pre validate-checksums attribution local-images helm/build  attribution-pr github-rate-limit-post`
release: ## Called via prow postsubmit + release jobs, calls `validate-checksums images helm/push `
########### END GENERATED ###########################
