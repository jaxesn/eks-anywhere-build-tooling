ARG BASE_IMAGE # public.ecr.aws/amazonlinux/amazonlinux:2023-minimal
ARG BUILDER_IMAGE

FROM $BUILDER_IMAGE as builder

RUN set -x && \
    enable_extra docker && \
    install_binary /usr/bin/docker-init && \
    cleanup "deps"

    
FROM $BASE_IMAGE

ARG MOBY_CONFIG
LABEL "org.mobyproject.config"="${MOBY_CONFIG}"

RUN dnf install -y \
        findutils \
        procps \
        sed \
        util-linux \
        which && \
    ln -s setsid /usr/bin/setsid.getty && \
    dnf clean all

COPY --from=builder /newroot/usr/bin/docker-init /usr/bin/docker-init

COPY linuxkit/pkg/getty/usr/ /usr/
COPY linuxkit/pkg/getty/etc/ /etc/

ENTRYPOINT ["/usr/bin/docker-init", "-s", "-v", "--"]
CMD ["/usr/bin/rungetty.sh"]
