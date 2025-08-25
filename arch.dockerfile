# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_ROOT=/go/backup
  ARG BUILD_BIN=${BUILD_ROOT}/backup

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/distroless:tini-pm AS distroless-tini-pm

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: BACKUP
  FROM 11notes/go:1.25 AS build
  COPY ./build /
  ARG APP_VERSION \
      BUILD_ROOT \
      BUILD_BIN \
      TARGETARCH \
      TARGETPLATFORM \
      TARGETVARIANT

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    eleven go build ${BUILD_BIN} main.go;

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};


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
    COPY --from=util / /
    COPY --from=distroless-tini-pm / /
    COPY --from=build /distroless/ /
    COPY ./rootfs /

# :: RUN
  USER root

  RUN set -ex; \
    eleven mkdir ${APP_ROOT}/{etc,var,sql,backup,log,run}; \
    ln -sf ${APP_ROOT}/run /run/postgresql; \
    apk --no-cache --update add \
      cmd:usermod \
      cmd:groupmod \
      lz4 \
      postgresql${APP_VERSION} \
      postgresql${APP_VERSION}-contrib; \
    ln -sf /dev/stdout ${APP_ROOT}/log/stdout.json; \
    eleven changeUserToDocker postgres; \
    chmod +x -R /usr/local/bin; \
    chown -R ${APP_UID}:${APP_GID} \
      /tini-pm \
      ${APP_ROOT}; \
    apk del cmd:usermod cmd:groupmod;

# :: STORAGE
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: HEALTH
  HEALTHCHECK --interval=5s --timeout=2s --start-interval=5s \
    CMD ["pg_isready", "-U", "postgres"]

# :: INIT
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/tini-pm"]