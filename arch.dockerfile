ARG APP_UID=1000
ARG APP_GID=1000

# :: Util
  FROM 11notes/util AS util

# :: Header
  FROM 11notes/distroless:tini-pm AS tini-pm
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
    ENV TINI_PM_CONFIG=/tini-pm/config.yml

  # :: multi-stage
    COPY --from=util --chown=${APP_UID}:${APP_GID} /usr/local/bin/ /usr/local/bin
    COPY --from=tini-pm --chown=${APP_UID}:${APP_GID} / /

# :: Run
  USER root
  RUN eleven printenv;

  # :: prepare image
    RUN set -ex; \
      eleven mkdir ${APP_ROOT}/{etc,var,sql,backup,log,run};

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
      chown -R ${APP_UID}:${APP_GID} \
        /tini-pm \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD pg_isready -U postgres &>/dev/null || exit 1

# :: Start
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/tini-pm", "--socket"]