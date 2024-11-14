# :: QEMU
  FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Header
  FROM --platform=linux/arm64 11notes/alpine:stable
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  ENV APP_NAME="postgres"
  ENV APP_VERSION=16
  ENV APP_ROOT=/postgres

# :: Run
  USER root

  # :: prepare image
		RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc; \
			mkdir -p ${APP_ROOT}/var; \
      mkdir -p ${APP_ROOT}/sql; \
      mkdir -p ${APP_ROOT}/backup; \
      mkdir -p ${APP_ROOT}/run; \
      mkdir -p ${APP_ROOT}/log;

  # :: install applications
    RUN set -ex; \
      apk --no-cache --update add \
        lz4 \
        postgresql16 \
        postgresql16-contrib; \
      ln -sf /dev/stdout /postgres/log/stdout.json; \
      ln -sf /postgres/run /run/postgresql;

  # :: set uid/gid to 1000:1000 for existing user
    RUN set -ex; \
      NOROOT_USER="postgres" \
      NOROOT_UID="$(id -u ${NOROOT_USER})"; \
      NOROOT_GID="$(id -g ${NOROOT_USER})"; \
      find / -not -path "/proc/*" -user ${NOROOT_UID} -exec chown -h -R 1000:1000 {} \;;\
      find / -not -path "/proc/*" -group ${NOROOT_GID} -exec chown -h -R 1000:1000 {} \;; \
      usermod -d ${APP_ROOT} docker;

  # :: copy root filesystem changes and set correct permissions
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R 1000:1000 \
        ${APP_ROOT}

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var", "${APP_ROOT}/sql", "${APP_ROOT}/backup"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]