ARG ALPINE_VERSION=3.21.2
FROM gautada/alpine:$ALPINE_VERSION as SOURCE

ARG IMAGE_VERSION=0.16.2

WORKDIR /opt
RUN apk add --no-cache go build-base git \
 && git config --global advice.detachedHead false \
 && git clone --branch "v${IMAGE_VERSION}" --depth 1 https://github.com/sosedoff/pgweb.git

WORKDIR /opt/pgweb
RUN make build

# │ STAGE: CONTAINER
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――
FROM gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭―
# │ METADATA
# ╰――――――――――――――――――――
LABEL org.opencontainers.image.title="pgweb"
LABEL org.opencontainers.image.description="A pgweb database manager container."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/pgweb"
LABEL org.opencontainers.image.source="https://github.com/gautada/pgweb"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=pgweb
# Set shell to /bin/ash and enable pipefail for Alpine-based images
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN /usr/sbin/usermod -l $USER alpine \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER alpine \
 && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ PRIVILEGES (OFF)
# ╰――――――――――――――――――――
# COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP (OFF)
# ╰――――――――――――――――――――
# COPY backup /etc/container/backup

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY --from=SOURCE /pgweb/pgweb /usr/bin/pgweb
RUN /sbin/apk add --no-cache postgresql17-client \
&& mkdir -p /etc/container/secrets \
&& chown $USER:$USER -R /etc/container/secrets

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
USER $USER
RUN /bin/ln -fsv /mnt/volumes/container/pgweb /home/$USER/.pgweb
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER
