ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-glibc
ARG BUILDER_IMAGE

FROM $BUILDER_IMAGE as touch-builder

RUN set -x && \
    yumdownloader --destdir=/tmp/downloads coreutils && \
    cd /newroot && \
    rpm2cpio /tmp/downloads/coreutils*.rpm | cpio -idv ./usr/bin/touch


################ Validate #######################
FROM touch-builder as run_validate

RUN set -x && \
    validate_libraries && \
    validate_symlinks && \
    touch /tmp/validate-success


FROM $BASE_IMAGE

WORKDIR /

COPY --from=touch-builder /newroot/usr/bin/touch /usr/bin/touch

# ensure run_validate stage runs
COPY --from=run_validate /tmp/validate-success /dev/null

ENTRYPOINT [ "/usr/bin/touch", "/worker/reboot" ]
