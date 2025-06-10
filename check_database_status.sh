#!/bin/bash

# Configuration
DB_HOST="<IP_Address>"
DB_PORT=5432  # PostgreSQL default port
TIMEOUT=5
STATUS_FILE="/tmp/db_status.txt"
DISCORD_WEBHOOK_URL="<webhook_URL>"

# Function to check if the database is reachable
check_db() {
  nc -z -w $TIMEOUT $DB_HOST $DB_PORT
  return $?
}

# Send message to Discord
send_discord() {
  local message="$1"
  curl -s -H "Content-Type: application/json" \
       -X POST \
       -d "{\"content\": \"$message\"}" \
       "$DISCORD_WEBHOOK_URL" > /dev/null
}

# Load last known status
if [ -f "$STATUS_FILE" ]; then
  LAST_STATUS=$(cat "$STATUS_FILE")
else
  LAST_STATUS="unknown"
fi

# Check current status
if check_db; then
  CURRENT_STATUS="up"
else
  CURRENT_STATUS="down"
fi

# If status changed, send alert
if [ "$CURRENT_STATUS" != "$LAST_STATUS" ]; then
  if [ "$CURRENT_STATUS" == "down" ]; then
    send_discord "🚨 Alert: PostgreSQL database on \`${DB_HOST}:${DB_PORT}\` is **DOWN**!"
  else
    send_discord "✅ Notice: PostgreSQL database on \`${DB_HOST}:${DB_PORT}\` is **back online**."
  fi
  echo "$CURRENT_STATUS" > "$STATUS_FILE"
fi