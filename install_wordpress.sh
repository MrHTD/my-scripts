#!/bin/bash

# Exit on error
set -e

# === PARAMETER CHECK ===
if [ -z "$1" ]; then
  echo "❌ Usage: $0 <custom_folder_name>"
  exit 1
fi

CUSTOM_NAME="$1"

# === CONFIGURATION ===
SOURCE_DIR="/home/devxonic/Downloads"
ARCHIVE_NAME="latest.tar.gz"
DEST_DIR="/var/www/html"

# === SCRIPT EXECUTION ===

echo "Changing to source directory: $SOURCE_DIR"
cd "$SOURCE_DIR"

echo "Extracting WordPress archive: $ARCHIVE_NAME"
if [[ "$ARCHIVE_NAME" == *.zip ]]; then
    unzip -o "$ARCHIVE_NAME"
elif [[ "$ARCHIVE_NAME" == *.tar.gz ]]; then
    tar -xzf "$ARCHIVE_NAME"
else
    echo "❌ Unsupported archive format: $ARCHIVE_NAME"
    exit 1
fi

echo "Moving 'wordpress' to $DEST_DIR/$CUSTOM_NAME ..."
sudo rm -rf "$DEST_DIR/$CUSTOM_NAME"  # Remove if exists
sudo mv wordpress "$DEST_DIR/$CUSTOM_NAME"

echo "Setting ownership and permissions..."
sudo chown -R www-data:www-data "$DEST_DIR/$CUSTOM_NAME"
sudo chmod -R 755 "$DEST_DIR/$CUSTOM_NAME"

echo "✅ WordPress successfully deployed at $DEST_DIR/$CUSTOM_NAME"