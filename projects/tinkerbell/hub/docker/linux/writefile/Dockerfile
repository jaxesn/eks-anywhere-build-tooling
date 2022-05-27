ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-glibc
ARG BUILDER_IMAGE
################ Validate #######################
FROM $BUILDER_IMAGE  as run_validate

ARG TARGETARCH
ARG TARGETOS

COPY _output/dependencies/$TARGETOS-$TARGETARCH/eksa/torvalds/linux/tools/bootconfig /newroot/usr/bin/bootconfig

RUN set -x && \
    validate_libraries && \
    validate_symlinks && \
    touch /tmp/validate-success


FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

ARG ATTRIBUTION_FILE

COPY _output/bin/hub/$TARGETOS-$TARGETARCH/writefile /usr/bin/writefile
COPY _output/writefile/LICENSES /LICENSES
COPY $ATTRIBUTION_FILE /ATTRIBUTION.txt

# ensure run_validate stage runs
COPY --from=run_validate /newroot/usr/bin/bootconfig /usr/bin/bootconfig
COPY _output/dependencies/$TARGETOS-$TARGETARCH/eksa/torvalds/linux/ATTRIBUTION.txt /BOOTCONFIG_ATTRIBUTION.txt
COPY _output/dependencies/$TARGETOS-$TARGETARCH/eksa/torvalds/linux/LICENSES /BOOTCONFIG_LICENSES

ENTRYPOINT ["/usr/bin/writefile"]
