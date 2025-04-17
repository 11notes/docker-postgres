${{ content_synopsis }} This image will run postgres as postgres with the database postgres and the password you set initially. Why so simple? Because 99.9% of all containers that need postgres, are happy with the default settings, no different dbname, different dbuser, whatever needed. It also adds a simple `backup` command to backup the entire database. This command can be executed on a schedule by using [11notes/cron]/(https://hub.docker.com/r/11notes/cron).

This image contains [cmd-socket](https://github.com/11notes/go-cmd-socket) exposed via ```/run/cmd/cmd.sock```, you can mount it to other images to issue commands on this image (like backup schedule) via curl. It uses [tini-pm](https://github.com/11notes/go-tini-pm) to start the postgres and cmd-socket process.
 
${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of config files
* **${{ json_root }}/var** - Directory of database files

${{ content_compose }}

${{ title_example }}
To take a full backup simply run
```shell
docker exec ${{ IMAGE }} backup
```

${{ content_defaults }}
| `config` | ${{ json_root }}/etc/default.conf | default configuration file |

${{ content_environment }}
| `POSTGRES_PASSWORD` | password for user postgres |  |

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}