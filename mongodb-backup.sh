#!/bin/bash

# Settings
DB_HOST="$MONGO_HOST"
DB_NAME="$MONGO_DATABASE"
DB_USER="$MONGO_USER"
DB_PASS="$MONGO_PASS"
BUCKET_NAME="$BUCKET"

# Path in which to create the backup (will get cleaned later)
BACKUP_PATH="/mnt/data/dump/"

# Loops each word in $DB_NAME
for DB_NAME_EACH in $DB_NAME
  CURRENT_DATE=$(date +"%Y%m%d-%H%M")

  # Backup filename
  BACKUP_FILENAME="$DB_NAME_EACH-$CURRENT_DATE.tar.gz"

  # Create the backup
  mongodump -h "$DB_HOST" -d "$DB_NAME_EACH" -u "$DB_USER" -p "$DB_PASS" -o "$BACKUP_PATH"
  cd $BACKUP_PATH || exit

  # Archive and compress
  tar -cvzf "$BACKUP_PATH""$BACKUP_FILENAME" ./*

  # Copy to Google Cloud Storage
  echo "Copying $BACKUP_PATH$BACKUP_FILENAME to gs://$BUCKET_NAME/$DB_NAME_EACH/"
  /root/gsutil/gsutil cp "$BACKUP_PATH""$BACKUP_FILENAME" gs://"$BUCKET_NAME"/"$DB_NAME_EACH"/ 2>&1
done
echo "Copying finished"
echo "Removing backup data"
rm -rf $BACKUP_PATH*
