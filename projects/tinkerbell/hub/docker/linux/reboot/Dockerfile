ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base
ARG BUILDER_IMAGE

FROM $BUILDER_IMAGE as touch-builder

RUN set -x && \
    install_binary /usr/bin/touch && \
    cleanup "touch"    

FROM $BASE_IMAGE

WORKDIR /

COPY --from=touch-builder /newroot/usr/bin/touch /usr/bin/touch

ENTRYPOINT [ "/usr/bin/touch", "/worker/reboot" ]
