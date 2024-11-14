#!/bin/ash
  if [ -z "$(ls -A ${APP_ROOT}/var)" ]; then
    elevenLogJSON info "creating new database"
    initdb --username=postgres --pwfile=<(printf "%s\n" "${POSTGRES_PASSWORD}") --pgdata ${APP_ROOT}/var &>/dev/null
    ln -sf ${APP_ROOT}/etc/default.conf ${APP_ROOT}/var/postgresql.conf
  else
    elevenLogJSON info "loading existing database"
  fi

  if [ -z "${1}" ]; then
    if [ ! -z "$(ls -A ${APP_ROOT}/sql)" ]; then
      postgres --config-file=${APP_ROOT}/etc/default.conf &> /dev/null &
      elevenLogJSON info "executing SQL scripts ..."
      sleep 5
      find ${APP_ROOT}/sql -type f -regex '.*\.sql' -exec psql -U postgres -d postgres -a -f {} &> /dev/null \;
      kill -9 $(pgrep -f 'postgres')
      rm -rf ${APP_ROOT}/sql/*
      sleep 5
    fi

    elevenLogJSON info "starting ${APP_NAME} v${APP_VERSION}"
    set -- postgres \
      --config-file=${APP_ROOT}/etc/default.conf
  fi

  exec "$@"