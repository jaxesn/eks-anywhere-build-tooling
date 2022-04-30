BINARY_TARGET_FILES:=foo bar
SOURCE_PATTERNS:=./cmd/foo ./cmd/bar
IMAGE_NAMES=foo bar
FOO_IMAGE_COMPONENT=testing/foo
BAR_IMAGE_COMPONENT=testing/bar

EXTRA_ARG=awesome-arg
IMAGE_BUILD_ARGS=EXTRA_ARG

foo/images/%: BASE_IMAGE_NAME=eks-distro-minimal-base-git
