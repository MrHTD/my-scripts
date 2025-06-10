#!/bin/bash

# Configuration
HOST="<IP_Address>"
PORT=22
TIMEOUT=5
STATUS_FILE="/tmp/server_status.txt"
DISCORD_WEBHOOK_URL="<webhook_URL>"

# Function to check if the server is reachable
check_db() {
  nc -z -w "$TIMEOUT" "$HOST" "$PORT"
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
  TIMESTAMP=$(date "+%Y-%m-%d %I:%M %p")
  if [ "$CURRENT_STATUS" == "down" ]; then
    send_discord "🚨 Alert: Devxonic Server on \`${HOST}\` is **DOWN** as of $TIMESTAMP!"
  else
    send_discord "✅ Notice: Devxonic Server on \`${HOST}\` is **back online** as of $TIMESTAMP."
  fi
  echo "$CURRENT_STATUS" > "$STATUS_FILE"
fi
