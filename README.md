![banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# POSTGRES
[<img src="https://img.shields.io/badge/github-source-blue?logo=github&color=040308">](https://github.com/11notes/docker-POSTGRES)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![size](https://img.shields.io/docker/image-size/11notes/postgres/16?color=0eb305)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![version](https://img.shields.io/docker/v/11notes/postgres/16?color=eb7a09)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![pulls](https://img.shields.io/docker/pulls/11notes/postgres?color=2b75d6)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)[<img src="https://img.shields.io/github/issues/11notes/docker-POSTGRES?color=7842f5">](https://github.com/11notes/docker-POSTGRES/issues)![5px](https://github.com/11notes/defaults/blob/main/static/img/transparent5x2px.png?raw=true)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxwYXRoIGQ9Im0wIDBoMzJ2MzJoLTMyeiIgZmlsbD0iI2YwMCIvPjxwYXRoIGQ9Im0xMyA2aDZ2N2g3djZoLTd2N2gtNnYtN2gtN3YtNmg3eiIgZmlsbD0iI2ZmZiIvPjwvc3ZnPg==)

PostgreSQL as simple and secure as it gets

# SYNOPSIS 📖
**What can I do with this?** This image will run postgres as postgres with the database postgres and the password you set initially. Why so simple? Because 99.9% of all containers that need postgres, are happy with the default settings, no different dbname, different dbuser, whatever needed. It also adds a simple `backup` command to backup the entire database. This command can be executed on a schedule by using [11notes/cron]/(https://hub.docker.com/r/11notes/cron) automatically. This image is using [tini-pm](https://github.com/11notes/go-tini-pm) as init to start the database process as well as cmd-socket.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! All the other images on the market that do exactly the same don’t do or offer these options:

> [!IMPORTANT]
>* This image runs as 1000:1000 by default, most other images run everything as root
>* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
>* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
>* This image works as read-only, most other images need to write files to the image filesystem
>* This image is a lot smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | 11notes/postgres:16 | postgres:16-alpine |
| ---: | :---: | :---: |
| **image size on disk** | 64.3MB | 275MB |
| **process UID/GID** | 1000/1000 | 0/0 |
| **distroless?** | ❌ | ❌ |
| **rootless?** | ✅ | ❌ |

 
# VOLUMES 📁
* **/postgres/etc** - Directory of config files
* **/postgres/var** - Directory of database files

# COMPOSE ✂️
```yaml
name: "postgres"
services:
  server:
    image: "11notes/postgres:16"
    read_only: true
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
    tmpfs:
      # needed for read-only file system to work
      - "/run/postgresql:uid=1000,gid=1000"
      - "/postgres/log:uid=1000,gid=1000"
    restart: "always"

  cron:
    depends_on:
      postgres:
        condition: "service_healthy"
        restart: true
    image: "11notes/cron:4.6"
    environment:
      TZ: "Europe/Zurich"
      # run backup every day at 03:00
      CRONTAB: |-
        0 3 * * * cmd-socket '{"bin":"backup"}' > /proc/1/fd/1
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

*created 14.05.2025, 10:13:23 (CET)*