<img alt="BlueSpice Logo" align="right" src="https://bluespice.com/wp-content/uploads/2022/09/bluespice_logo.png" />

# `bluespice/helper` service for BlueSpice

## Helper for installation and upgrades
runs as prepare service to create Directory-Tree and set Correct permissions
` command : prepare bluespice `

## Runs as upgrade-helper
Upgrades a BlueSpice 5.x installation to 6.x. Upgrades from older versions are not supported.

```
tree /app/bin/upgrade6x
upgrade6x
└── 010-rename-secrets (keeps the values of secrets renamed since 5.x, e.g. `INTERNAL_CHAT_WIKI_ACCESS_TOKEN` -> `INTERNAL_CHAT_WIKI_API_KEY`)
```

The scripts run once, in order. See logs at `$DATADIR/wiki/bluespice/logs/backend_upgrade_6.log`

#### Commands
` command : upgrade-pipeline`

force rerun

` command : upgrade-pipeline -f`


#### Use with bluespice-deploy

To run the automated upgrade use `./bluespice-deploy up -d --profile=upgrade`

Run `./bluespice-deploy up -d --profile=upgrade-force` to force a rerun of the upgrade scripts

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
