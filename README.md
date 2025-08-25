![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# POSTGRES
![size](https://img.shields.io/docker/image-size/11notes/postgres/16?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/postgres/16?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/postgres?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-POSTGRES?color=7842f5">](https://github.com/11notes/docker-POSTGRES/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

PostgreSQL as simple and secure as it gets

# INTRODUCTION 📢

PostgreSQL is a powerful, open-source, object-relational database management system known for its reliability, feature set, and adherence to standards. It supports both SQL (relational) and JSON (non-relational) querying and is backed by a large, active community.

# SYNOPSIS 📖
**What can I do with this?** This image will run postgres as postgres with the database postgres and the password you set initially. Why so simple? Because 99.9% of all containers that need postgres, are happy with the default settings, no different dbname, different dbuser, whatever needed. It also adds a simple backup scheduler that will backup your database if ``` POSTGRES_BACKUP_SCHEDULE``` is set. It allows for incremental backups too if enabled.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small
>* ... this image can take full and incremental backups on its own

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/postgres:16 | 46MB | 1000:1000 | ❌ | armv7, arm64, amd64 |
| postgres:16-alpine | 276MB | 0:0 | ❌ | amd64, armv6, armv7, arm64v8, 386, ppc64le, riscv64, s390x |
 
# VOLUMES 📁
* **/postgres/etc** - Directory of config files
* **/postgres/var** - Directory of database files

# COMPOSE ✂️
```yaml
name: "db"
services:
  postgres:
    image: "11notes/postgres:16"
    read_only: true
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      # make a full and compressed database backup each day at 03:00
      POSTGRES_BACKUP_SCHEDULE: "0 3 * * *"
    ports:
      - "5432:5432/tcp"
    networks:
      frontend:
    volumes:
      - "postgres.etc:/postgres/etc"
      - "postgres.var:/postgres/var"
      - "postgres.backup:/postgres/backup"
    tmpfs:
      # needed for read-only
      - "/postgres/run:uid=1000,gid=1000"
      - "/postgres/log:uid=1000,gid=1000"
    restart: "always"

volumes:
  postgres.etc:
  postgres.var:
  postgres.backup:

networks:
  frontend:
```

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /postgres | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |
| `POSTGRES_BACKUP_SCHEDULE` | Set backup schedule for full backups (crontab style) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [16](https://hub.docker.com/r/11notes/postgres/tags?name=16)

# REGISTRIES ☁️
```
docker pull 11notes/postgres:16
docker pull ghcr.io/11notes/postgres:16
docker pull quay.io/11notes/postgres:16
```

# SOURCE 💾
* [11notes/postgres](https://github.com/11notes/docker-POSTGRES)

# PARENT IMAGE 🏛️
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH 🧰
* [postgres](https://github.com/postgres/postgres)
* [11notes/util](https://github.com/11notes/docker-util)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-postgres/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-postgres/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-postgres/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 25.08.2025, 09:44:59 (CET)*