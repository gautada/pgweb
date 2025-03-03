ARG ALPINE_VERSION=3.21.2

# │ STAGE: BUILD                                      
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
FROM gautada/alpine:$ALPINE_VERSION as SOURCE

ARG CONTAINER_VERSION=0.16.2
ARG PGWEB_BRANCH=v"$CONTAINER_VERSION"

RUN apk add --no-cache go build-base git \
 && git config --global advice.detachedHead false \
 && git clone --branch $PGWEB_BRANCH --depth 1 https://github.com/sosedoff/pgweb.git

WORKDIR /pgweb
RUN make build
# RUN make setup \
#  && make dev


# │ STAGE: CONTAINER
# ╰―――――――――――――――――――――――――――――――――――――――――――――――――
FROM gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭―
# │ METADATA
# ╰――――――――――――――――――――
LABEL source="https://github.com/gautada/pgweb-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A PostgreSQL GUI container via pgweb"

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
RUN /sbin/apk add --no-cache postgresql15-client

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
