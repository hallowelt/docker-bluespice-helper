<img alt="BlueSpice Logo" align="right" src="https://bluespice.com/wp-content/uploads/2022/09/bluespice_logo.png" />

# `bluespice/helper` service for BlueSpice

## Helper for installation and upgrades
runs as prepare service to create Directory-Tree and set Correct permissions
` command : prepare bluespice `

## Runs as upgrade-helper

```
tree /app/bin/upgrade5x
upgrade5x
├── upgrade-databases (Prevents braking DB on upgrade)
├── upgrade_db.sql
├── upgrade-filesystem(Renames Directories for FARM)
├── upgrade-mongo-db(dumps Mongo5 collabpads and recreates the db in Mongo8)
└── upgrade-tasks(empty)
```

Each update script creates backups at ` $DATADIR/upgrade_backup `

See logs at `$DATADIR/wiki/bluespice/logs/backend_upgrade_5.log`

#### Commands
` command : upgrade-pipeline`

force rerun

` command : upgrade-pipeline -f`


#### Use with bluespice-deploy

To run the automated upgrade use `./bluespice-deploy up -d --profile=upgrade`

Run `./bluespice-deploy up -d -profile=upgrade-force` to force rerun the update-scripts and update.php in Wiki

## Backup

Runs as a scheduled backup service via `supercronic`.

**Command:** `run-backups`

### Environment Variables

#### Scheduling
| Variable | Default | Description |
|---|---|---|
| `BACKUP_TIME` | `0 2 * * *` | Cron expression for the backup schedule. Falls back to default if the value is not a valid cron string. |

#### Directories
| Variable | Default | Description |
|---|---|---|
| `BLUESPICE_BACKUP_DIRECTORY` | `/data/backup/restic` | Target directory for Restic backups |
| `BLUESPICE_DATABASE_BACKUP_DIRECTORY` | `/data/wiki/db_backup` | Directory for database dumps |
| `BLUESPICE_TAR_BACKUP_DIRECTORY` | `/data/backup/tar-backup` | Target directory for TAR backups |

#### Passwords
| Variable | Description |
|---|---|
| `BLUESPICE_BACKUP_PASS` | Password for the Restic repository (auto-generated and saved to `/data/wiki/.wikienv` if not set) |
| `BACKUP_PASS` | Password used by `restic forget` during cleanup |

#### Database
| Variable | Default | Description |
|---|---|---|
| `DB_HOST` | `database` | MariaDB hostname |
| `DB_NAME` | – | Database name |
| `DB_USER` | `bluespice` | Database user |
| `DB_PASS` | – | Database password |
| `DB_PREFIX` | – | Table prefix |

#### Behaviour
| Variable | Description |
|---|---|
| `TAR_BACKUP` | If set, use TAR backup instead of Restic |
| `BLUESPICE_BACKUP_RETENTION_TIME` | Retention time in days for TAR backups (default: `5`) |
| `WIKI_HOST` | Wiki hostname — used for TAR archive filenames |
| `EDITION` | Set to `farm` to enable multi-instance farm backup |
| `WIKI_FARM_USE_SHARED_DB` | *(Farm only)* Set if all farm instances share a single database |

---

## Testing

Build the image with:

```bash
docker build --no-cache --pull -t bluespice/helper:latest .
```

Test the `prepare-bluespice` command with:
```bash
docker run --rm \
	-v /tmp/helper$(date +%s):/data \
	-e EDITION=farm \
	-e WIKI_HOST=wiki.company.local \
	bluespice/helper:latest prepare-bluespice
```
