#!/bin/ash
  if [ -z "$(ls -A ${APP_ROOT}/var)" ]; then
    eleven log info "creating new database"
    initdb --username=postgres --pwfile=<(printf "%s\n" "${POSTGRES_PASSWORD}") --pgdata ${APP_ROOT}/var &>/dev/null
    ln -sf ${APP_ROOT}/etc/default.conf ${APP_ROOT}/var/postgresql.conf
  else
    eleven log info "loading existing database"
  fi

  if [ -z "${1}" ]; then

    if [ ! -z "${POSTGRES_BACKUP_INCREMENTAL}" ]; then
      eleven log info "archive mode active!"
      sed -i 's/#archive_mode = off/archive_mode = on/' ${APP_ROOT}/etc/default.conf
    else
      sed -i 's/archive_mode = on/#archive_mode = off/' ${APP_ROOT}/etc/default.conf
    fi

    if [ ! -z "$(ls -A ${APP_ROOT}/sql)" ]; then
      postgres --config-file=${APP_ROOT}/etc/default.conf &> /dev/null &
      eleven log info "executing SQL scripts ..."
      sleep 5
      find ${APP_ROOT}/sql -type f -regex '.*\.sql' -exec psql -U postgres -d postgres -a -f {} &> /dev/null \;
      kill -9 $(pgrep -f 'postgres')
      rm -rf ${APP_ROOT}/sql/*
      sleep 5
    fi

    rm -rf ${APP_ROOT}/var/postmaster.pid

    set -- postgres \
      --config-file=${APP_ROOT}/etc/default.conf
    eleven log start
  fi

  exec "$@"