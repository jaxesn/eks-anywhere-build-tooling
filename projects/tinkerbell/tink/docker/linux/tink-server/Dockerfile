ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-glibc
ARG BUILDER_IMAGE

FROM $BUILDER_IMAGE as wget-builder

WORKDIR /newroot

RUN set -x && \
    clean_install "wget" && \
    remove_package "bash coreutils gawk info sed grep" && \
    cleanup "wget"


################ Validate #######################
FROM wget-builder as run_validate

RUN set -x && \
    validate_libraries && \
    validate_symlinks && \
    touch /tmp/validate-success


FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

WORKDIR /

COPY --from=wget-builder /newroot /

COPY _output/dependencies/$TARGETOS-$TARGETARCH/eksa/cloudflare/cfssl /usr/local/bin
COPY _output/bin/tink/$TARGETOS-$TARGETARCH/tink-server /usr/bin/tink-server
COPY _output/LICENSES /LICENSES
COPY ATTRIBUTION.txt /ATTRIBUTION.txt

# ensure run_validate stage runs
COPY --from=run_validate /tmp/validate-success /dev/null

EXPOSE 42113
EXPOSE 42114

ENTRYPOINT ["/usr/bin/tink-server"]
