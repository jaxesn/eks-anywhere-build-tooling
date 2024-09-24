ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-glibc
ARG BUILDER_IMAGE
FROM $BUILDER_IMAGE as builder

RUN set -x && \
    install_binary /usr/sbin/modprobe && \
    cleanup "deps"

FROM $BASE_IMAGE

ARG MOBY_CONFIG
LABEL "org.mobyproject.config"="${MOBY_CONFIG}"

COPY --from=builder /newroot /
