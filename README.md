![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - Postgres
![size](https://img.shields.io/docker/image-size/11notes/postgres/16?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/postgres/16?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/postgres?color=2b75d6)

**PostgreSQL for Docker**

# SYNOPSIS
What can I do with this? This image will run postgres as postgres with the database postgres and the password you set initially. Why so simple? Because 99.9% of all containers that need postgres, are happy with the default settings, no different dbname, different dbuser, whatever needed. It also adds a simple `backup` command to backup the entire database.

# VOLUMES
* **/postgres/etc** - Directory of config files
* **/postgres/var** - Directory of database files
* **/postgres/backup** - Directory of backups

# COMPOSE
```yaml
services:
  postgres:
    image: "11notes/postgres:16"
    container_name: "postgres"
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: "*********"
    ports:
      - "5432:5432/tcp"
    volumes:
      - "var:/postgres/var"
      - "backup:/postgres/backup"
    restart: "always"
volumes:
  var:
  backup:
```

To take a full backup simply run
```shell
docker exec postgres backup
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
| `POSTGRES_PASSWORD` | password for user postgres |  |

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [postgres](https://www.postgresql.org)
* [alpine](https://alpinelinux.org)

# TIPS
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes. You can find all my repositories on [github](https://github.com/11notes).
    