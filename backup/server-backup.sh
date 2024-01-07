#!/usr/bin/env bash

#### MANUAL INITIALIZATION STEPS ####
# install restic (v0.16 or higher)
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

# shellcheck disable=SC1091
# shellcheck source=.backup.env
source .backup.env

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export RESTIC_PASSWORD=$RESTIC_PASSWORD

timestamp=$(date '+%Y-%m-%d--%H-%M-%S')

log="/home/oasis/logs/backups/$timestamp"
touch "$log"

# Variables
BACKUP_FILE_LIST="backup_directories.txt"
S3_ENDPOINT="$B2_S3_URL/$B2_BUCKET_NAME"
BACKUP_DATA_DIR="/mnt/data/BACKUPS"

# Databases requiring 'pg_dump' export location identified by:
#     <db-container-name>:<dbname>:<db_user>
declare -a DATABASES=(nextcloud_NCDatabase_1:NC:nextcloud immich_postgres:immich:postgres)

# Main

## Iterate over DATABASES, create postgres dump into BACKUPS
for db_string in "${DATABASES[@]}"; do
  {
    echo "$timestamp Parsing db string: '$db_string'"
    container="$(echo "$db_string" | cut -d ':' -f 1)"
    database="$(echo "$db_string" | cut -d ':' -f 2)"
    db_user="$(echo "$db_string" | cut -d ':' -f 3)"

    # Ensure backup directories are created
    mkdir -p "$BACKUP_DATA_DIR/$container"

    docker exec -it "$container" pg_dump -U "$db_user" "$database" >"$BACKUP_DATA_DIR/$container/$(date +%Y-%m-%d)-$container.sql"

    if [ $? -eq 0 ]; then
      echo "$timestamp Successfully backed up '$database' in '$container'"
    else
      echo "$timestamp ERROR: pg_dump encountered issue with '$container'"
    fi

  } >>"$log"
done

## Backup all directories + DB backups with Restic

# shellcheck disable=SC2086
{
  ### Dry run backup
  echo "=== BEGIN DRY-RUN - $timestamp ==="

  restic -r s3:$S3_ENDPOINT backup -v --dry-run --tag "scheduled-$(date +%Y-%m-%d)" --files-from $BACKUP_FILE_LIST
  exc=$?

  if [ $exc -ne 0 ]; then
    echo "$timestamp error in dry run, exit code: $exc"
    exit 1
  fi
  echo "=== END DRY-RUN - $timestamp ==="

  ### Full backup w/ very verbose
  restic -r s3:$S3_ENDPOINT backup -vv --tag "scheduled-$(date +%Y-%m-%d)" --files-from $BACKUP_FILE_LIST
} >>"$log"

exit 0
