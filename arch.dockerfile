# :: Util
  FROM 11notes/util AS util

# :: Command Socket
  FROM golang:1.23-alpine AS cmd
  RUN set -ex; \
    apk --update --no-cache add \
      git; \
    git clone https://github.com/11notes/go-cmd-socket.git; \
    cd /go/go-cmd-socket; \
    go build; \
    mv go-cmd-socket /usr/local/bin/cmd-socket;

# :: Header
  FROM 11notes/alpine:stable

  # :: arguments
    ARG TARGETARCH
    ARG APP_IMAGE
    ARG APP_NAME
    ARG APP_VERSION
    ARG APP_ROOT
    ARG APP_UID
    ARG APP_GID

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE}
    ENV APP_NAME=${APP_NAME}
    ENV APP_VERSION=${APP_VERSION}
    ENV APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=util /usr/local/bin/ /usr/local/bin
    COPY --from=cmd /usr/local/bin/cmd-socket /usr/local/bin

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      eleven mkdir ${APP_ROOT}/{etc,var,sql,backup,log,run}; \
      mkdir -p /run/cmd;

  # :: install application
    RUN set -ex; \
      apk --no-cache --update add \
        lz4 \
        postgresql${APP_VERSION} \
        postgresql${APP_VERSION}-contrib; \
      ln -sf /dev/stdout ${APP_ROOT}/log/stdout.json; \
      ln -sf ${APP_ROOT}/run /run/postgresql;

  # :: set uid/gid to 1000:1000 for existing user
    RUN set -ex; \
      eleven changeUserToDocker postgres;

  # :: copy filesystem changes and set correct permissions
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R 1000:1000 \
        /run/cmd \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD pg_isready -U postgres &>/dev/null || exit 1

# :: Start
  USER docker