ARG BASE_IMAGE # public.ecr.aws/amazonlinux/amazonlinux:2023-minimal
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

# this makes sure that the multi stage build copies as a symlink
RUN cd /bin && ln -s rc.init rc.shutdown

# volumes link to start
RUN mkdir -p /etc/init.d && ln -s /usr/bin/service /etc/init.d/005-volumes

# Add /etc/ssl/certs so it can be bind-mounted into metadata package
RUN mkdir -p /etc/ssl/certs

COPY _output/bin/linuxkit/$TARGETOS-$TARGETARCH/usermode-helper /
COPY _output/bin/linuxkit/$TARGETOS-$TARGETARCH/init /
COPY _output/bin/linuxkit/$TARGETOS-$TARGETARCH/rc.init /bin/rc.init
COPY _output/bin/linuxkit/$TARGETOS-$TARGETARCH/service /usr/bin/service

COPY linuxkit/pkg/init/etc/ etc/

COPY INIT_ATTRIBUTION.txt /bin
COPY RC.INIT_ATTRIBUTION.txt /bin
COPY SERVICE_ATTRIBUTION.txt /bin

RUN set -x && \
    if [ $TARGETARCH = "amd64" ]; then BUSYBOX_ARCH="x86_64"; else BUSYBOX_ARCH="armv81"; fi && \
    curl https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-$BUSYBOX_ARCH -o /usr/bin/busybox && \
    chmod +x /usr/bin/busybox && \
    ln -sf /usr/bin/busybox /sbin/init && \
    ln -sf /usr/bin/busybox /sbin/mdev

RUN set -x && \
    dnf install -y gzip iproute \
        libseccomp \
        pigz \
        tar \
        util-linux && \
    dnf clean all
