#!/bin/ash
  if [ -z "$(ls -A ${APP_ROOT}/var)" ]; then
    elevenLogJSON info "creating new database"
    initdb --username=postgres --pwfile=<(printf "%s\n" "${POSTGRES_PASSWORD}") --pgdata ${APP_ROOT}/var &>/dev/null
    ln -sf ${APP_ROOT}/etc/default.conf ${APP_ROOT}/var/postgresql.conf
  else
    elevenLogJSON info "loading existing database"
  fi

  if [ -z "${1}" ]; then
    elevenLogJSON info "starting ${APP_NAME} (${APP_VERSION})"
    set -- postgres \
      --config-file=${APP_ROOT}/etc/default.conf
  fi

  exec "$@"