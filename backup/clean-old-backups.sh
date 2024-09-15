#!/bin/bash

# shellcheck source=common.sh
source common.sh

log_retention_days=30
db_backup_retention_days=14

# TODO: Cleanup old logs file by date (keep only 30-60 days)
echo "Cleaning old logs in: '$LOG_DIR'"
find "$LOG_DIR" -name "*.log" -mtime +$log_retention_days -type f -delete
echo "Done"

# iterate over each backup directory in DB_BACKUP_DIR
for dir in "$DB_BACKUP_DIR"/*/
do
  echo "Cleaning old backups in: '$dir'"
  find "$dir" -name "*.sql" -mtime +$db_backup_retention_days -type f -delete
  echo "Done"
done

