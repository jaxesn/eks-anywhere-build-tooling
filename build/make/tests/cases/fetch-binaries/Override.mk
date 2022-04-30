BINARY_TARGET_FILES:=foo
IMAGE_NAMES:=foo
FETCH_BINARIES_TARGETS=eksa/distribution/distribution

foo/images/amd64: _output/dependencies/linux-amd64/$(FETCH_BINARIES_TARGETS)
