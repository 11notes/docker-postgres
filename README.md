![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - Postgres
![size](https://img.shields.io/docker/image-size/11notes/postgres/16?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/postgres/16?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/postgres?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-postgres?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-postgres?color=c91cb8) ![stars](https://img.shields.io/docker/stars/11notes/postgres?color=e6a50e)

**PostgreSQL for Docker**

# SYNOPSIS
What can I do with this? This image will run postgres as postgres with the database postgres and the password you set initially. Why so simple? Because 99.9% of all containers that need postgres, are happy with the default settings, no different dbname, different dbuser, whatever needed. It also adds a simple `backup` command to backup the entire database.

# VOLUMES
* **/postgres/etc** - Directory of config files
* **/postgres/var** - Directory of database files
* **/postgres/backup** - Directory of backups

# RUN
```shell
docker run --name postgres \
  -p 5432:5432/tcp \
  -v .../etc:/postgres/etc \
  -v .../var:/postgres/var \
  -v .../backup:/postgres/backup \
  -d 11notes/postgres:[tag]
```

To take a full backup simply run
```shell
docker exec postgres backup
```

# COMPOSE
```yaml
version: "3.8"
services:
  postgres:
    image: "11notes/postgres:16"
    container_name: "postgres"
    environment:
      POSTGRES_PASSWORD: *********
    ports:
      - "5432:5432/tcp"
    volumes:
      - "var:/postgres/var"
      - "backup:/postgres/backup"
volumes:
  var:
  backup:
```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /postgres | home directory of user docker |
| `config` | /postgres/etc/default.conf | default configuration file |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [postgres](https://www.postgresql.org)
* [alpine](https://alpinelinux.org)

# TIPS
* Only use rootless container runtime (podman, rootless docker)
* Allow non-root ports < 1024 via `echo "net.ipv4.ip_unprivileged_port_start=53" > /etc/sysctl.d/ports.conf`
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes.
    