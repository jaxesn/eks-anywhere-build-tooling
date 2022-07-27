ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-glibc
ARG BUILDER_IMAGE

FROM $BUILDER_IMAGE as ipmitool-builder

WORKDIR /newroot

ENV OPENIPMI_MODALIAS_IGNORE_SCRIPTLET_ERRORS="true"

RUN set -x && \
    install_rpm ipmitool && \
    cleanup "ipmitool"

FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY --from=ipmitool-builder /newroot /

COPY _output/bin/rufio/$TARGETOS-$TARGETARCH/manager /usr/bin/manager
COPY _output/LICENSES /LICENSES
COPY ATTRIBUTION.txt /ATTRIBUTION.txt

USER 65532:65532

ENTRYPOINT ["/usr/bin/manager"]