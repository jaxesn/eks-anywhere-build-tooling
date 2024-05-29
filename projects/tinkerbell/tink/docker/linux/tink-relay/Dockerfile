ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-glibc
ARG BUILDER_IMAGE
ARG GOLANG_GCC_BUILDER_IMAGE

FROM public.ecr.aws/eks-distro-build-tooling/golang:1.22-gcc-al2 as tini-builder
RUN set -x && \
    yum install cmake -y && \
    cd /tmp && \
    git clone https://github.com/krallin/tini.git && \
    cd tini && \
    cmake . && \
    make tini

FROM $BUILDER_IMAGE as builder

RUN set -x && \
    install_binary /usr/sbin/dhcrelay && \
    cleanup "deps"

FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY --from=tini-builder /tmp/tini/tini /sbin
COPY --from=tini-builder /tmp/tini/LICENSE /TINI_LICENSE
COPY --from=builder /newroot /


ENTRYPOINT ["/sbin/tini", "--", "dhcrelay", "-d"]
