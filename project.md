${{ content_synopsis }} This image will run postgres as postgres with the database postgres and the password you set initially. Why so simple? Because 99.9% of all containers that need postgres, are happy with the default settings, no different dbname, different dbuser, whatever needed. It also adds a simple `backup` command to backup the entire database. This command can be executed on a schedule by using [11notes/cron]/(https://hub.docker.com/r/11notes/cron) automatically. This image is using [tini-pm](https://github.com/11notes/go-tini-pm) as init to start the database process as well as cmd-socket.

${{ content_uvp }} Good question! All the other images on the market that do exactly the same don’t do or offer these options:

${{ github:> [!IMPORTANT] }}
${{ github:> }}* This image runs as 1000:1000 by default, most other images run everything as root
${{ github:> }}* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
${{ github:> }}* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
${{ github:> }}* This image works as read-only, most other images need to write files to the image filesystem
${{ github:> }}* This image is a lot smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

${{ content_comparison }}
 
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