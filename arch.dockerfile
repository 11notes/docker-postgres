# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
  # GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000

  # :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/distroless:tini-pm AS tini-pm


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
  # :: HEADER
  FROM 11notes/alpine:stable

  # :: arguments
    ARG TARGETARCH \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT} \
        TINI_PM_CONFIG=/tini-pm/config.yml

  # :: multi-stage
    COPY --from=util /usr/local/bin /usr/local/bin
    COPY --from=tini-pm / /

# :: RUN
  USER root
  RUN eleven printenv;

  # :: prepare image
    RUN set -ex; \
      eleven mkdir ${APP_ROOT}/{etc,var,sql,backup,log}; \
      eleven mkdir /run/{cmd,postgresql};

  # :: install application
    RUN set -ex; \
      apk --no-cache --update add \
        lz4 \
        postgresql${APP_VERSION} \
        postgresql${APP_VERSION}-contrib; \
      ln -sf /dev/stdout ${APP_ROOT}/log/stdout.json;

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

# :: STORAGE
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: HEALTH
  HEALTHCHECK --interval=5s --timeout=2s --start-interval=5s \
    CMD pg_isready -U postgres &>/dev/null

# :: INIT
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/tini-pm", "--socket"]