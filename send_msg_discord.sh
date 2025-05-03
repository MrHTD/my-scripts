#!/bin/bash

set -a
source .env
set +a

DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL}"

if [[ "$FILE_ID" == "null" || -z "$FILE_ID" ]]; then
    echo "Msg Send!" >&2
    curl -X POST -H "Content-Type: application/json" \
        -d '{"content": "Testing shell!."}' \
        "$DISCORD_WEBHOOK_URL"
    exit 1
fi
