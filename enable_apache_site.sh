#!/bin/bash

# Exit on error
set -e

# === PARAMETER CHECK ===
if [ "$#" -ne 2 ]; then
  echo "❌ Usage: $0 <new_file_name.conf> <new_port>"
  exit 1
fi

CUSTOM_NAME="$1"
NEW_PORT="$2"

# === CONFIGURATION ===
SOURCE_DIR="/etc/apache2/sites-available"
FILE_NAME="test.conf"
DEST_DIR="/etc/apache2/sites-available"
CONFIG_FILE="$DEST_DIR/$CUSTOM_NAME"

# Define the path based on the custom name
NEW_PATH="/var/www/html/${CUSTOM_NAME%.conf}"


# Ensure file ends with .conf
if [[ "$CUSTOM_NAME" != *.conf ]]; then
  echo "❌ The custom file name must end with '.conf'"
  exit 1
fi

# Check if source file exists
if [ ! -f "$SOURCE_DIR/$FILE_NAME" ]; then
  echo "❌ Source file '$FILE_NAME' not found in $SOURCE_DIR"
  exit 1
fi

# Copy the template config to the new custom config
echo "Copying $FILE_NAME to $CONFIG_FILE ..."
sudo cp "$SOURCE_DIR/$FILE_NAME" "$CONFIG_FILE"

# Update VirtualHost port
sudo sed -i "s|<VirtualHost \*:[0-9]\+>|<VirtualHost *:$NEW_PORT>|" "$CONFIG_FILE"

# Update DocumentRoot
sudo sed -i "s|DocumentRoot .*|DocumentRoot $NEW_PATH|" "$CONFIG_FILE"

# Update Directory block path
sudo sed -i "s|<Directory .*>|<Directory $NEW_PATH/>|" "$CONFIG_FILE"

echo "✅ Config copied and updated:"
echo "  File: $CONFIG_FILE"
echo "  Port: $NEW_PORT"
echo "  Path: $NEW_PATH"
