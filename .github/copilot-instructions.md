# Copilot Instructions for BlueSpice Helper

## Overview

This is a Docker image helper service for BlueSpice (a MediaWiki-based wiki platform) that provides three main functions:
1. **Preparation/Installation** - Directory setup and permissions
2. **Upgrades** - Migration from BlueSpice 4.x to 5.x
3. **Backups & Restore** - Multiple backup strategies (dump-only, TAR, Restic)

The entire codebase is shell scripts organized by function in `root-fs/app/bin/`.

## Build & Test

### Build the Docker Image
```bash
docker build --no-cache --pull -t bluespice/helper:latest .
```

### Test the Prepare Command
```bash
docker run --rm \
  -v /tmp/helper$(date +%s):/data \
  -e EDITION=farm \
  -e WIKI_HOST=wiki.company.local \
  bluespice/helper:latest prepare-bluespice
```

## Architecture & Script Organization

### Pipeline Pattern
All main commands follow a pipeline pattern: **one master script runs numbered subscripts in sequence**.

- **`prepare-bluespice`** - Runs all scripts in `prepare.d/` with prefix `NNN-*`
  - `010-init-data-directory` - Creates directory structure
  - `020-cleanup-mariadb` - Cleans up MariaDB binlog files
  - `030-ensure-oauth-keys` - Generates OAuth keys
  - `040-ensure-simplesamlphp-certs` - Creates SSL certificates
  - `050-ensure-wiki-secrets` - Sets up secrets (mostly symlinks for shared/single DB)
  - Cleans up binlog files at the end

- **`backup-pipeline`** - Runs all scripts in `backup.d/` with prefix `NNN-*`
  - `010-init-backup-repo` - Initializes repository (Restic-specific)
  - `020-backup-databases` - Dumps MariaDB to `/data/wiki/db-dumps/`
  - `030-backup-mongo-db` - Dumps MongoDB
  - `090-create-backup` - Creates TAR or Restic backup based on `BACKUP_TYPE`
  - `099-cleanup-backups` - Removes old backups (only for TAR backups)
  - Called by `run-backups` (wrapper for scheduling via supercronic)

- **`restore-pipeline`** - Runs all scripts in `restore.d/`
  - `010-extract-backup` - Unpacks TAR archive
  - `020-cleanup-directories` - Smart cleanup of only files in backup
  - `030-restore-wiki-data` - Extracts wiki files
  - `040-restore-mariadb` - Recreates MariaDB from SQL dumps
  - `050-restore-mongodb` - Recreates MongoDB
  - Called by `restore` wrapper (user-friendly CLI with confirmation)

### Upgrade Pipeline
- **`upgrade-pipeline`** - Orchestrates BlueSpice 4.x → 5.x migrations
- **`upgrade5x/`** directory contains version-specific upgrade scripts
  - `upgrade-databases` - Safely migrates DB structure
  - `upgrade-filesystem` - Renames directories for farm environments
  - `upgrade-mongo-db` - Dumps Mongo 5 collab pads, recreates in Mongo 8
  - Uses `-f` flag to force re-run if needed

## Key Conventions

### Environment Variables
Most configuration is via environment variables—see README.md for full list. Common ones:
- `EDITION=farm` or unset (single) - Determines data structure
- `BACKUP_TYPE=tar-file|dump-only|restic-repo` - Controls backup method
- `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`, `DB_PREFIX` - Database credentials
- `BLUESPICE_BACKUP_TIME='0 2 * * *'` - Cron expression for backup scheduling

### Defaults
- Backups go to `/backup/tar-backup/` (TAR), `/backup/restic-backup/` (Restic), or `/data/wiki/db-dumps/` (dump-only)
- Restore assumes backups in `BLUESPICE_TAR_BACKUP_DIRECTORY`
- Logs go to `/data/wiki/bluespice/logs/` with timestamp suffixes
- Farm editions check for single vs. shared database via `WIKI_FARM_USE_SHARED_DB`

### Script Exit Standards
All pipelines use strict mode:
```bash
set -o errexit    # Exit on error
set -o nounset    # Exit on undefined variable
set -o pipefail   # Fail on pipe errors
```

### Logging Convention
- Each pipeline subscript outputs `echo "🔧 Running /path/to/script"`
- restore-pipeline and backup-pipeline log all output with timestamps to:
  - `/data/wiki/bluespice/logs/backend_restore_YYYYMMDD_HHMMSS.log`
  - `/data/wiki/bluespice/logs/backend_upgrade_5.log`
- Wrapper commands (`restore`, `run-backups`) call main pipelines; they handle confirmation/scheduling

## When Modifying Scripts

- **Adding a new prepare step**: Create a new file in `prepare.d/NNN-name` (where NNN sorts correctly)
- **Adding a new backup method**: Implement in `backup.d/090-create-backup` with `if` blocks for `BACKUP_TYPE`
- **Adding a restore feature**: Create file in `restore.d/NNN-name` following pipeline pattern
- **Testing new scripts**: Remember `EDITION=farm` is a common test case for multi-instance scenarios
- **Database operations**: Always verify SQL syntax matches MariaDB (not generic MySQL)
- **Sensitive files**: OAuth keys and certificates must be protected with strict permissions (640/660)

## Testing Considerations

- The test command in README mounts a temporary `/data` volume; real deployments use persistent volumes
- Farm edition (`EDITION=farm`) requires different directory structures per instance
- Single DB (`WIKI_FARM_USE_SHARED_DB=1`) and multi-DB farm setups have different cleanup logic
- Backup retention only applies to `BACKUP_TYPE=tar-file` (set in `099-cleanup-backups`)
- Restore deliberately does NOT delete wiki files if `FILE_BACKUP=false` to prevent data loss
