ARG CONTAINER_VERSION=13.3

# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ STAGE 1: Build pgweb from source                                         │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM golang:1.24-trixie AS builder

RUN apt-get update \
 && apt-get install -y --no-install-recommends git jq curl \
 && rm -rf /var/lib/apt/lists/*

# Resolve the latest pgweb release tag and build from source.
RUN IMAGE_VERSION=$(curl -sL "https://api.github.com/repos/sosedoff/pgweb/releases/latest" \
      | jq -r '.tag_name' \
      | tr -d '[:space:]') \
 && { [ -n "$IMAGE_VERSION" ] && [ "$IMAGE_VERSION" != "null" ] \
      || { echo "ERROR: failed to resolve latest pgweb release from GitHub API" >&2; exit 1; }; } \
 && echo "Building pgweb ${IMAGE_VERSION}" \
 && git config --global advice.detachedHead false \
 && git clone --branch "$IMAGE_VERSION" --depth 1 https://github.com/sosedoff/pgweb.git /pgweb

WORKDIR /pgweb
RUN make build

# ╭――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╮
# │ STAGE 2: Final container image                                           │
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――╯
FROM docker.io/gautada/debian:${CONTAINER_VERSION} AS container

ARG IMAGE_NAME=pgweb

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A pgweb database browser container based on gautada/debian."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.license="MIT"

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
RUN apt-get update \
 && apt-get install -y --no-install-recommends jq \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=pgweb
RUN /usr/sbin/usermod -l $USER debian \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER debian \
 && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY --from=builder /pgweb/pgweb /usr/bin/pgweb

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
COPY version.sh /usr/bin/container-version
RUN chmod +x /usr/bin/container-version

# ╭――――――――――――――――――――╮
# │ LATEST             │
# ╰――――――――――――――――――――╯
COPY latest.sh /usr/bin/container-latest
RUN chmod +x /usr/bin/container-latest

# ╭――――――――――――――――――――╮
# │ HEALTH             │
# ╰――――――――――――――――――――╯
COPY appversion-check.sh /etc/container/health.d/appversion-check
RUN chmod +x /etc/container/health.d/appversion-check
COPY pgweb-running.sh /etc/container/health.d/pgweb-running
RUN chmod +x /etc/container/health.d/pgweb-running

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY pgweb.s6 /etc/services.d/pgweb/run
RUN chmod +x /etc/services.d/pgweb/run

VOLUME /mnt/volumes/configmaps
EXPOSE 8080/tcp

WORKDIR /home/${USER}
