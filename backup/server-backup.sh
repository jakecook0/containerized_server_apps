#!/usr/bin/env bash
# shellcheck source=.backup.env

#### MANUAL INITIALIZATION STEPS ####
# install restic
# Create new B2 bucket, set encryption, lifecycle as desired
# Create API key with access to new B2 bucket
# setup AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY exports with API key values
# Generate/create a password for the restic backups -- SAVE THIS OUT CAREFULLY
# run the following command, entering the password in respective prompts:
#   restic -r s3:s3.<REGION>.backblazeb2.com/<BUCKET-NAME> init
#   >> This init process can run from any machine, doesn't have to be the server
#      Just need the password used for init
#########

# Init

# TODO: check that 'backup_directores.txt' exists

source .backup.env

# TODO: setup log
log="/home/oasis/logs/backups/$(date +%Y-%m-%d)"

# Variables
BACKUP_FILE_LIST=backup_directories.txt
S3_ENDPOINT="https://$B2_REGION/$B2_BUCKET_NAME"
# Path of raw directories
ROOT_DATA_PATH="/mnt/data"
BACKUP_DATA_DIR="$ROOT_DATA_PATH/BACKUPS"

# Databases requiring 'pg_dump' export location identified by:
#     <db-container-name>:<dbname>:<db_user>
declare -a DATABASES=( nextcloud_NCDatabase_1:NC:nextcloud immich_postgres:immich:postgres )

# Main

## Iterate over DATABASES, create postgres dump into BACKUPS
for db_string in "${DATABASES[@]}"
do
  {
   echo "Parsing db string: '$db_string'"
   container="$(echo "$db_string" | cut -d ':' -f 1)"
   database="$(echo "$db_string" | cut -d ':' -f 2)"
   db_user="$(echo "$db_string" | cut -d ':' -f 3)"

   cmd=$(docker exec -it "$container" pg_dump -U "$db_user" "$database" > "$BACKUP_DATA_DIR/$container/$(date +%Y-%m-%d)-$container.sql")
   ## For local testing:
  #  cmd=$(echo $container)

   if [ "$cmd" ]; then
    echo "Successfully backed up '$database' in '$container'"
   else
     echo "ERROR: pg_dump encountered issue with '$container'"
   fi

  } >> $log
done

## Backup all directories + DB backups with Restic

### Dry run backup
# shellcheck disable=SC2086
restic -r s3:$S3_ENDPOINT backup --dry-run --tag "scheduled-$(date +%Y-%m-%d)" --files-from $BACKUP_FILE_LIST >> $log


### Full backup
# shellcheck disable=SC2086
restic -r s3:$S3_ENDPOINT backup --tag "scheduled-$(date +%Y-%m-%d)" --files-from $BACKUP_FILE_LIST >> $log

exit 0