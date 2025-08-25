${{ content_synopsis }} This image will run postgres as postgres with the database postgres and the password you set initially. Why so simple? Because 99.9% of all containers that need postgres, are happy with the default settings, no different dbname, different dbuser, whatever needed. It also adds a simple backup scheduler that will backup your database if ``` POSTGRES_BACKUP_SCHEDULE``` is set. It allows for incremental backups too if enabled.

${{ content_uvp }} Good question! Because ...

${{ github:> [!IMPORTANT] }}
${{ github:> }}* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
${{ github:> }}* ... this image has a health check
${{ github:> }}* ... this image runs read-only
${{ github:> }}* ... this image is automatically scanned for CVEs before and after publishing
${{ github:> }}* ... this image is created via a secure and pinned CI/CD process
${{ github:> }}* ... this image is very small
${{ github:> }}* ... this image can take full and incremental backups on its own

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

${{ content_comparison }}
 
${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of config files
* **${{ json_root }}/var** - Directory of database files

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}
| `POSTGRES_BACKUP_SCHEDULE` | Set backup schedule for full backups (crontab style) | |

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}