#!/bin/bash

# === CONFIGURATION ===
CONTAINER_ID="e26531bb38c8"
BACKUP_DIR="/home/devxonic/db_backups"
TIMESTAMP=$(date +"%Y-%m-%d_%I-%M-%p")
FILENAME="full-backup-$TIMESTAMP.sql"
FULL_PATH="$BACKUP_DIR/$FILENAME"

# Google OAuth credentials
CLIENT_ID="<YOUR_CLIENT_ID>"
CLIENT_SECRET="<YOUR_CLIENT_SECRET>"
REFRESH_TOKEN="<YOUR_REFRESH_TOKEN>"
FOLDER_ID="<YOUR_GOOGLE_DRIVE_FOLDER_ID>"

DISCORD_WEBHOOK_URL="<YOUR_DISCORD_WEBHOOK_URL>"

# === STEP 1: CREATE BACKUP ===
echo "Creating PostgreSQL backup..."
mkdir -p "$BACKUP_DIR"
sudo docker exec -t "$CONTAINER_ID" pg_dumpall -U postgres > "$FULL_PATH"

if [[ $? -ne 0 ]]; then
    echo "Database backup failed!"
    curl -X POST -H "Content-Type: application/json" \
        -d '{"content": "Backup failed! Database backup could not be created."}' \
        "$DISCORD_WEBHOOK_URL"
    exit 1
fi

# === STEP 2: GET ACCESS TOKEN ===
echo "Fetching Google Drive access token..."
ACCESS_TOKEN=$(curl --silent -X POST \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "grant_type=refresh_token" \
  https://oauth2.googleapis.com/token | jq -r '.access_token')

if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
    echo "Failed to retrieve Google Drive access token" >&2
    curl -X POST -H "Content-Type: application/json" \
        -d '{"content": "Backup failed! Could not retrieve Google Drive access token."}' \
        "$DISCORD_WEBHOOK_URL"
    exit 1
fi

# === STEP 3: UPLOAD TO GOOGLE DRIVE ===
echo "Uploading backup to Google Drive..."
uploadResponse=$(curl -X POST -L --progress-bar \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -F "metadata={\"name\": \"$FILENAME\", \"parents\": [\"$FOLDER_ID\"]};type=application/json;charset=UTF-8" \
  -F "file=@$FULL_PATH" \
  "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")

FILE_ID=$(echo "$uploadResponse" | jq -r '.id')

if [[ "$FILE_ID" == "null" || -z "$FILE_ID" ]]; then
    echo "Upload failed!" >&2
    curl -X POST -H "Content-Type: application/json" \
        -d '{"content": "Backup failed! File upload to Google Drive failed."}' \
        "$DISCORD_WEBHOOK_URL"
    exit 1
fi

# === STEP 4: MAKE FILE PUBLIC ===
curl -s -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role": "reader", "type": "anyone"}' \
  "https://www.googleapis.com/drive/v3/files/$FILE_ID/permissions" > /dev/null

# === DONE ===
echo "Backup uploaded successfully!"
echo "Public Link: https://drive.google.com/file/d/$FILE_ID/view"


# Get current date and time in human-readable form
CURRENT_DATE=$(date +"%A, %B %d, %Y at %I:%M %p")

# Send success message to Discord
curl -X POST -H "Content-Type: application/json" \
    -d '{
        "content": "**Backup Completed Successfully**\n\n**Backup Date:** '"$CURRENT_DATE"'\n\nThe database backup was successfully created and uploaded to Google Drive. You can access the backup using the following link:\n[View Backup on Google Drive](https://drive.google.com/file/d/'"$FILE_ID"'/view)"
    }' \
    "$DISCORD_WEBHOOK_URL"