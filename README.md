![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# ⛰️ postgres
[<img src="https://img.shields.io/badge/github-source-blue?logo=github&color=040308">](https://github.com/11notes/docker-postgres)![size](https://img.shields.io/docker/image-size/11notes/postgres/16?color=0eb305)![version](https://img.shields.io/docker/v/11notes/postgres/16?color=eb7a09)![pulls](https://img.shields.io/docker/pulls/11notes/postgres?color=2b75d6)[<img src="https://img.shields.io/github/issues/11notes/docker-postgres?color=7842f5">](https://github.com/11notes/docker-postgres/issues)

PostgreSQL, as simple and secure as it gets

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [16](https://hub.docker.com/r/11notes/postgres/tags?name=16)
* [latest](https://hub.docker.com/r/11notes/postgres/tags?name=latest)

# SYNOPSIS 📖
**What can I do with this?** This image will run postgres as postgres with the database postgres and the password you set initially. Why so simple? Because 99.9% of all containers that need postgres, are happy with the default settings, no different dbname, different dbuser, whatever needed. It also adds a simple `backup` command to backup the entire database. This command can be executed on a schedule by using [11notes/cron]/(https://hub.docker.com/r/11notes/cron).

This image contains [cmd-socket](https://github.com/11notes/go-cmd-socket) exposed via ```/run/cmd/.sock```, you can mount it to other images to issue commands on this image (like backup schedule) via curl.
 
# VOLUMES 📁
* **/postgres/etc** - Directory of config files
* **/postgres/var** - Directory of database files

# COMPOSE ✂️
```yaml
name: "postgres"
services:
  postgres:
    image: "11notes/postgres:16"
    container_name: "postgres"
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    ports:
      - "5432:5432/tcp"
    volumes:
      - "etc:/postgres/etc"
      - "var:/postgres/var"
      - "backup:/postgres/backup"
      - "cmd:/run/cmd"
    restart: "always"

  cron:
    depends_on:
      postgres:
        condition: "service_healthy"
        restart: true
    image: "11notes/cron:stable"
    container_name: "cron"
    environment:
      TZ: "Europe/Zurich"
      CRONTAB: |-
        0 3 * * * cmd /run/cmd/.sock backup > /proc/1/fd/1
    volumes:
      - "cmd:/run/cmd"
    restart: "always"

volumes:
  etc:
  var:
  backup:
  cmd:
```

${{ title_example }}
To take a full backup simply run
```shell
docker exec ${{ IMAGE }} backup
```

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /postgres | home directory of user docker |
| `config` | /postgres/etc/default.conf | default configuration file |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |
| `POSTGRES_PASSWORD` | password for user postgres |  |

# SOURCE 💾
* [11notes/postgres](https://github.com/11notes/docker-postgres)

# PARENT IMAGE 🏛️
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH 🧰
* [postgres](https://github.com/postgres/postgres)

# GENERAL TIPS 📌
* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-postgres/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-postgres/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-postgres/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 12.3.2025, 10:03:35 (CET)*