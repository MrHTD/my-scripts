# my-scripts

A collection of useful Bash scripts for various tasks, including server management, backups, and automation.

## Scripts Overview

### 1. `enable_apache_site.sh`
- **Description**: Automates the process of enabling a new Apache site configuration.
- **Usage**: `./enable_apache_site.sh <new_file_name.conf> <new_port>`

### 2. `install_wordpress.sh`
- **Description**: Installs WordPress in a specified directory with proper permissions.
- **Usage**: `./install_wordpress.sh <custom_folder_name>`

### 3. `pg_backup.sh`
- **Description**: Creates a PostgreSQL database backup and uploads it to Google Drive.
- **Usage**: Configure `.env` with required credentials and run the script.

### 4. `send_msg_discord.sh`
- **Description**: Sends a test message to a Discord channel using a webhook.
- **Usage**: Configure `.env` with `DISCORD_WEBHOOK_URL` and run the script.

### 5. `check_server_status.sh`
- **Description**: Monitors a server's status (up/down) and sends a Discord notification if the status changes.
- **Usage**: Edit the script to set `HOST`, `PORT`, and `DISCORD_WEBHOOK_URL`, then run it periodically (e.g., via cron).

### 6. `check_database_status.sh`
- **Description**: Checks if a PostgreSQL database is reachable and sends a Discord alert if its status changes.
- **Usage**: Edit the script to set `DB_HOST`, `DB_PORT`, and `DISCORD_WEBHOOK_URL`, then run it periodically.

### 7. `ufw_ports_remove.sh`
- **Description**: Removes a range of allowed TCP ports from UFW (Uncomplicated Firewall).
- **Usage**: `./ufw_ports_remove.sh`

## Prerequisites
- Ensure you have the necessary permissions to execute the scripts.
- Install required dependencies such as `curl`, `jq`, `docker`, `unzip`, and `netcat` (`nc`).

## Setup
1. Clone the repository.
2. Make the scripts executable:
   ```bash
   chmod +x *.sh
   ```