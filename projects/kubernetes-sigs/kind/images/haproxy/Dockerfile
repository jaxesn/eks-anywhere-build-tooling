ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-haproxy
ARG BUILDER_IMAGE
FROM $BUILDER_IMAGE as haproxy-builder

RUN set -x && \
    install_binary /usr/bin/cp \
        /usr/bin/mkdir \
        /usr/bin/kill &&\
    cleanup "haproxy"

FROM $BASE_IMAGE

COPY --from=haproxy-builder /newroot /

# upstream minimal config
COPY --chown=haproxy:haproxy _output/files/haproxy/usr /usr

# below roughly matches the standard haproxy image
STOPSIGNAL SIGUSR1
ENTRYPOINT ["haproxy", "-sf", "7", "-W", "-db", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
