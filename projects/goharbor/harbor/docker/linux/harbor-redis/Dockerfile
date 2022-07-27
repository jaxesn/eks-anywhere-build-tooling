ARG BASE_IMAGE
ARG BUILDER_IMAGE
FROM $BUILDER_IMAGE as redis-builder

WORKDIR /

RUN set -x \
    enable_extra redis6 && \
    install_rpm redis && \
    cleanup "redis"


FROM $BASE_IMAGE

COPY --from=redis-builder /newroot/ /
COPY --chown=redis:redis _output/harbor-redis _output/LICENSES ATTRIBUTION.txt /

VOLUME /var/lib/redis
WORKDIR /var/lib/redis

USER redis
CMD ["/usr/bin/redis-server", "/etc/redis.conf"]