# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
ARG BASE_IMAGE # https://gallery.ecr.aws/eks-distro-build-tooling/eks-distro-minimal-base-nginx
ARG BUILDER_IMAGE
FROM $BUILDER_IMAGE as nginx-builder
ARG IMAGE_TAG=not-set

RUN set -x && \
    install_rpm bash && \
    install_binary /usr/bin/echo \
        /usr/bin/mkdir \
        /usr/bin/tee \
        /usr/bin/cat \
        /usr/bin/envsubst \
        /usr/bin/ln \
        /usr/bin/tr && \
    cleanup "nginx"

RUN set -x && \
    echo $IMAGE_TAG > $NEWROOT/IMAGE_TAG && \
    # chmod 755 $NEWROOT/var/log/nginx && \
    ln -sf /dev/stdout $NEWROOT/var/log/nginx/access.log && \
    ln -sf /dev/stderr $NEWROOT/var/log/nginx/error.log && \
    chmod -R 777 $NEWROOT/usr/share/nginx

ARG BASE_IMAGE
FROM $BASE_IMAGE

COPY --from=nginx-builder /newroot /

ADD --chown=nginx:nginx conf/index.template /usr/share/nginx/
ADD --chown=nginx:nginx conf/default.conf /etc/nginx/conf.d/
ADD --chown=nginx:nginx conf/hello.sh /hello.sh

VOLUME /var/log/nginx /run /usr/share/nginx

STOPSIGNAL SIGQUIT
ENTRYPOINT ["/hello.sh"]
CMD ["nginx", "-g", "daemon off;"]
