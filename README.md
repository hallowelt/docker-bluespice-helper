## Helper for Installation and upgrades
runs as prepare service to create Directory-Tree and set Correct permissions
´command : prepare bluespice´
## Runs as upgrade-helper
´´´
tree upgrade5x                                                                                                
upgrade5x
├── list.sql
├── upgrade-databases (Prevents braking DB on upgrade)
├── upgrade_db.sql
├── upgrade-filesystem(Renames Directories for FARM)
├── upgrade-mongo-db(dumps Mongo5 collabpads and recreates the db in Mongo8)
└── upgrade-tasks(empty)
´´´
Each update script creates backups at ´$DATADIR/upgrade_backup ´ 

For Correct usage run upgrade-pipeline
seé Logs at ´$DATADIR/wiki/bluespice/logs/backend_upgrade_5.log´

run upgrade-pipline -f to force rerun the update-scripts and update.php in Wiki
