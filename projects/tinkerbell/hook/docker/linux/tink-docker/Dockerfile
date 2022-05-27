ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-glibc
ARG BUILDER_IMAGE
FROM $BUILDER_IMAGE as docker-builder

ARG TARGETARCH

WORKDIR /newroot

RUN set -x && \
    amazon-linux-extras enable docker && \
    cp /etc/yum.repos.d/amzn2-extras.repo /newroot/etc/yum.repos.d/amzn2-extras.repo && \
    clean_install "systemd" true true && \
    clean_install "docker procps e2fsprogs" && \
    remove_package "bash coreutils gawk info sed shadow-utils grep" && \
    remove_package "systemd" true && \
    cleanup "tink-docker" && \
    if [ $TARGETARCH = "amd64" ]; then BUSYBOX_ARCH="x86_64"; else BUSYBOX_ARCH="armv81"; fi && \
    curl https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-$BUSYBOX_ARCH -o /newroot/usr/bin/busybox && \
    chmod +x /newroot/usr/bin/busybox && \
    ln -sf /usr/bin/busybox /newroot/usr/sbin/reboot && \
    ln -sf /usr/bin/docker-init /newroot/usr/local/bin/docker-init && \
    ln -sf /usr/bin/dockerd /newroot/usr/local/bin/dockerd


################ Validate #######################
FROM docker-builder as run_validate

RUN set -x && \
    validate_libraries && \
    validate_symlinks && \
    touch /tmp/validate-success


FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

WORKDIR /

COPY --from=docker-builder /newroot /

COPY _output/bin/hook/$TARGETOS-$TARGETARCH/tink-docker /usr/bin/tink-docker
COPY _output/tink-docker/LICENSES /LICENSES
COPY TINK_DOCKER_ATTRIBUTION.txt /ATTRIBUTION.txt

# ensure run_validate stage runs
COPY --from=run_validate /tmp/validate-success /dev/null

ENTRYPOINT [ "/usr/bin/tink-docker" ]
