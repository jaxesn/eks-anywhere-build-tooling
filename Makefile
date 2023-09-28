MAKEFLAGS+=--no-builtin-rules --warn-undefined-variables
SHELL=bash
.SHELLFLAGS:=-eu -o pipefail -c

BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
BUILD_LIB=${BASE_DIRECTORY}/build/lib
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2
IMAGE_REPO?=$(if $(AWS_ACCOUNT_ID),$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com,localhost:5000)
ECR_PUBLIC_URI?=$(shell aws ecr-public describe-registries --region us-east-1 --query 'registries[0].registryUri' --output text)
JOB_TYPE?=

RELEASE_BRANCH?=
GIT_HASH:=$(shell git -C $(BASE_DIRECTORY) rev-parse HEAD)
ALL_PROJECTS=$(shell $(BUILD_LIB)/all_projects.sh $(BASE_DIRECTORY))

# $1 - project name using _ as separator, ex: rancher_local-path-provisoner
PROJECT_PATH_MAP=projects/$(patsubst $(firstword $(subst _, ,$(1)))_%,$(firstword $(subst _, ,$(1)))/%,$(1))

BUILDER_PLATFORM_ARCH:=$(if $(filter x86_64,$(shell uname -m)),amd64,arm64)
# Locale settings impact file ordering in ls or shell file expansion. The file order is used to
# generate files that are subsequently validated by the CI. If local environments use different 
# locales to the CI we get unexpected failures that are tricky to debug without knowledge of 
# locales so we'll explicitly warn here.
# In a AL2 container image (like builder base), LANG will be empty which is equivalent to posix
# In a AL2 (or other distro) full instance the LANG will be en-us.UTF-8 which produces different sorts
# On Mac, LANG will be en-us.UTF-8 but has a fix applied to sort to avoid the difference
ifeq ($(shell uname -s),Linux)
  TO_LOWER = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst \
	F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst \
	M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst \
	T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$(subst _,-,$(1))))))))))))))))))))))))))))
	
  LOCALE:=$(call TO_LOWER,$(shell locale | grep LANG | cut -d= -f2 | tr -d '"'))
  LOCALE:=$(if $(LOCALE),$(LOCALE),posix)
  ifeq ($(filter c.utf-8 posix,$(LOCALE)),)
    $(warning WARNING: Environment locale set to $(LANG). On Linux systems this may create \
	non-deterministic behavior when running generation recipes. If the CI fails validation try \
	`LANG=C.UTF-8 make <recipe>` to generate files instead.)
  endif
endif

.PHONY: clean-project-%
clean-project-%:
	$(eval PROJECT_PATH=$(call PROJECT_PATH_MAP,$*))
	$(MAKE) clean -C $(PROJECT_PATH)

.PHONY: clean
clean: $(addprefix clean-project-, $(ALL_PROJECTS))
	rm -rf _output

.PHONY: build-all
build-all: build-all-warning $(foreach project,$(ALL_PROJECTS),$(call PROJECT_PATH_MAP,$(project))/eks-anywhere-full-buld-complete)

%/eks-anywhere-full-buld-complete: export RELEASE_BRANCH=1-27
%/eks-anywhere-full-buld-complete:
	@if [[ "$(@D)" == *"aws/cluster-api-provider-aws-snow"* ]]; then \
		echo "Skipping aws/cluster-api-provider-aws-snow: container images are pulled cross account"; \
		exit; \
	elif [[ "$(@D)" == *"prometheus/prometheus"* ]]; then \
		echo "Running make create-ecr-repos images for prometheus/node_exporter "; \
		make -C projects/prometheus/node_exporter create-ecr-repos images IMAGE_PLATFORMS=linux/$(BUILDER_PLATFORM_ARCH); \
	elif [[ "$(@D)" == *"cilium/cilium"* ]]; then \
		echo "Skipping cilium/cilium: due to odd helm pull"; \
		exit; \
	elif [[ "$(@D)" == *"kubernetes-sigs/image-builder"* ]]; then \
		export SKIP_METAL_INSTANCE_TEST=true; \
	elif [[ "$(@D)" == *"goharbor/harbor"* ]]; then \
		echo "skipping goharbor/harbor: unknown"; \
		exit; \
	elif [[ "$(@D)" == *"containerd/containerd"* ]]; then \
		echo "skipping containerd/containerd: unknown"; \
		exit; \
	elif [[ "$(@D)" == *"opencontainers/runc"* ]]; then \
		echo "skipping opencontainers/runc: unknown"; \
		exit; \
	elif [[ "$(@D)" == *"tinkerbell/hook"* ]]; then \
		echo "skipping tinkerbell/hook: unknown"; \
		exit; \
	elif [[ "$(@D)" == *"tinkerbell/hub"* ]]; then \
		echo "skipping tinkerbell/hub: unknown"; \
		exit; \
	elif [[ "$(@D)" == *"tinkerbell/tinkerbell-chart"* ]]; then \
		echo "skipping tinkerbell/tinkerbell-chart: unknown"; \
		exit; \
	fi; \
	if [ "$$($(MAKE) --no-print-directory -C $(@D) var-value-HAS_HELM_CHART)" = "true" ] && [ "$$($(MAKE) --no-print-directory -C $(@D) var-value-IMAGE_NAMES)" = "true" ]; then \
		echo "Running make create-ecr-repos images for $(@D) "; \
		make -C $(@D) create-ecr-repos; \
		make -C $(@D) images IMAGE_PLATFORMS=linux/$(BUILDER_PLATFORM_ARCH); \
	fi; \
	echo "Running make build for $(@D) "; \
	make --no-print-directory -C $(@D) build; \
	touch $@

.PHONY: build-all-warning
build-all-warning:
	@echo "*** Warning: this target is not meant to used except for specific testing situations ***"
	@echo "*** this will likely fail and either way run for a really long time ***"

.PHONY: add-generated-help-block-project-%
add-generated-help-block-project-%:
	$(eval PROJECT_PATH=$(call PROJECT_PATH_MAP,$*))
	$(MAKE) add-generated-help-block -C $(PROJECT_PATH) RELEASE_BRANCH=1-26

.PHONY: add-generated-help-block
add-generated-help-block: $(addprefix add-generated-help-block-project-, $(ALL_PROJECTS))
	build/update-attribution-files/create_pr.sh

.PHONY: attribution-files-project-%
attribution-files-project-%:
	$(eval PROJECT_PATH=$(call PROJECT_PATH_MAP,$*))
	$(MAKE) -C $(PROJECT_PATH) all-attributions

.PHONY: attribution-files
attribution-files: $(addprefix attribution-files-project-, $(ALL_PROJECTS))
	cat _output/total_summary.txt

.PHONY: checksum-files-project-%
checksum-files-project-%:
	$(eval PROJECT_PATH=$(call PROJECT_PATH_MAP,$*))
	$(MAKE) -C $(PROJECT_PATH) all-checksums

.PHONY: update-checksum-files
update-checksum-files: $(addprefix checksum-files-project-, $(ALL_PROJECTS))
	build/lib/update_go_versions.sh
	build/update-attribution-files/create_pr.sh

.PHONY: update-attribution-files
update-attribution-files: add-generated-help-block attribution-files
	build/update-attribution-files/create_pr.sh

.PHONY: stop-docker-builder
stop-docker-builder:
	docker rm -f -v eks-a-builder

.PHONY: run-buildkit-and-registry
run-buildkit-and-registry:
	docker run -d --name buildkitd --net host --privileged moby/buildkit:v0.10.6-rootless
	docker run -d --name registry  --net host registry:2

.PHONY: stop-buildkit-and-registry
stop-buildkit-and-registry:
	docker rm -v --force buildkitd
	docker rm -v --force registry

.PHONY: generate-project-list
generate-project-list:
	build/lib/generate_projects_list.sh $(BASE_DIRECTORY)

.PHONY: generate-staging-buildspec
generate-staging-buildspec:
	build/lib/generate_staging_buildspec.sh $(BASE_DIRECTORY) "$(ALL_PROJECTS)" "$(BASE_DIRECTORY)/release/staging-build.yml"
	build/lib/generate_staging_buildspec.sh $(BASE_DIRECTORY) "$(ALL_PROJECTS)" "$(BASE_DIRECTORY)/release/checksums-build.yml" true EXCLUDE_FROM_CHECKSUMS_BUILDSPEC CHECKSUMS_BUILDSPECS false buildspecs/checksums-pr-buildspec.yml
	build/lib/generate_staging_buildspec.sh $(BASE_DIRECTORY) "aws_bottlerocket-bootstrap" "$(BASE_DIRECTORY)/projects/aws/bottlerocket-bootstrap/buildspecs/batch-build.yml" true
	build/lib/generate_staging_buildspec.sh $(BASE_DIRECTORY) "kubernetes_cloud-provider-vsphere" "$(BASE_DIRECTORY)/projects/kubernetes/cloud-provider-vsphere/buildspecs/batch-build.yml" true
	build/lib/generate_staging_buildspec.sh $(BASE_DIRECTORY) "kubernetes-sigs_kind" "$(BASE_DIRECTORY)/projects/kubernetes-sigs/kind/buildspecs/batch-build.yml" true
	build/lib/generate_staging_buildspec.sh $(BASE_DIRECTORY) "containerd_containerd" "$(BASE_DIRECTORY)/projects/containerd/containerd/buildspecs/batch-build.yml" true
	build/lib/generate_staging_buildspec.sh $(BASE_DIRECTORY) "opencontainers_runc" "$(BASE_DIRECTORY)/projects/opencontainers/runc/buildspecs/batch-build.yml" true

.PHONY: generate
generate: generate-project-list generate-staging-buildspec

.PHONY: validate-generated
validate-generated: generate validate-eksd-releases
	@if [ "$$(git status --porcelain -- UPSTREAM_PROJECTS.yaml release/staging-build.yml release/checksums-build.yml **/batch-build.yml | wc -l)" -gt 0 ]; then \
		echo "Error: Generated files, UPSTREAM_PROJECTS.yaml release/staging-build.yml release/checksums-build.yml batch-build.yml, do not match expected. Please run `make generate` to update"; \
		git diff -- UPSTREAM_PROJECTS.yaml release/staging-build.yml release/checksums-build.yml **/batch-build.yml; \
		exit 1; \
	fi
	build/lib/readme_check.sh

.PHONY: check-project-path-exists
check-project-path-exists:
	@if ! stat $(PROJECT_PATH) &> /dev/null; then \
		echo "false"; \
	else \
		echo "true"; \
	fi

.PHONY: validate-eksd-releases
validate-eksd-releases:
	build/lib/validate_eksd_releases.sh
