ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-glibc
ARG BUILDER_IMAGE

FROM $BUILDER_IMAGE as sleep-builder

# sleep comes from the coreutils package which pulls in more deps than we need
# manually installing sleep from the rpm
# sleep only depends on glibc so there are no additional deps needed
RUN set -x && \
    yumdownloader --destdir=/tmp/downloads coreutils && \
    cd /newroot && \
    rpm2cpio /tmp/downloads/coreutils*.rpm | cpio -idv ./usr/bin/sleep


################ Validate #######################
FROM sleep-builder as run_validate

RUN set -x && \
    validate_libraries && \
    validate_symlinks && \
    touch /tmp/validate-success


FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

WORKDIR /

COPY --from=sleep-builder /newroot/usr/bin/sleep /usr/bin/
COPY _output/bin/tink/$TARGETOS-$TARGETARCH/tink /usr/bin/tink
COPY _output/LICENSES /LICENSES
COPY ATTRIBUTION.txt /ATTRIBUTION.txt

# ensure run_validate stage runs
COPY --from=run_validate /tmp/validate-success /dev/null

ENTRYPOINT ["/usr/bin/sleep", "infinity"]
